#!/bin/bash

# Цветовые переменные для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Путь к установке XMRig
XMRIG_PATH="/opt/xmrig"
LOG_FILE="$XMRIG_PATH/logs/xmrig.log"
MONITOR_SCRIPT="/usr/local/bin/monitor_xmrig.sh"

echo -e "${BLUE}Обновление системы и установка зависимостей...${NC}"
apt update && apt upgrade -y
apt install build-essential cmake libuv1-dev libssl-dev libhwloc-dev git screen cpulimit -y

# Скачивание и сборка XMRig
echo -e "${BLUE}Скачивание и сборка XMRig...${NC}"
git clone https://github.com/xmrig/xmrig.git "$XMRIG_PATH"
cd "$XMRIG_PATH"
mkdir build
cd build
cmake ..
make

# Создание файла конфигурации 
echo -e "${BLUE}Создание файла конфигурации...${NC}"
mkdir -p "$XMRIG_PATH/logs"
cat << EOF > "$XMRIG_PATH/build/config.json"
{
    "algo": "rx/0",
    "url": "pool.supportxmr.com:3333",
    "user": "ВАШ_MONERO_Кошелек",
    "pass": "x",
    "rig-id": "мой_сервер",
    "threads": 4,
    "cpu-priority": 5,
    "donate-level": 1,
    "log-file": "$LOG_FILE",
    "log-level": 0
}
EOF

# Создание службы systemd для XMRig
echo -e "${BLUE}Создание службы systemd для XMRig...${NC}"
cat << EOF > /etc/systemd/system/xmrig.service
[Unit]
Description=XMRig CPU Miner Service
After=network.target

