
#!/bin/bash

# Цветовые переменные для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Путь к установке XMRig
XMRIG_PATH="/opt/xmrig"
LOG_FILE="$XMRIG_PATH/logs/xmrig.log"
ERROR_LOG_DIR="$XMRIG_PATH/error_logs"
ERROR_LOG_FILE="$ERROR_LOG_DIR/error.log"
MONITOR_SCRIPT="/usr/local/bin/monitor_xmrig.sh"

# Функция для обработки ошибок
handle_error() {
    echo -e "${RED}Произошла ошибка: $1${NC}"
    echo "$(date) - $1" >> "$ERROR_LOG_FILE"
    exit 1
}

# Создание директории для логов ошибок
mkdir -p "$ERROR_LOG_DIR" || handle_error "Не удалось создать директорию для логов ошибок"

echo -e "${BLUE}Обновление системы и установка зависимостей...${NC}"
apt update && apt upgrade -y || handle_error "Не удалось обновить систему"
apt install -y build-essential cmake libuv1-dev libssl-dev libhwloc-dev git screen cpulimit libmicrohttpd-dev || handle_error "Не удалось установить зависимости"

# Скачивание и сборка XMRig
echo -e "${BLUE}Скачивание и сборка XMRig...${NC}"
git clone https://github.com/xmrig/xmrig.git "$XMRIG_PATH" || handle_error "Не удалось клонировать репозиторий XMRig"
cd "$XMRIG_PATH" || handle_error "Не удалось перейти в директорию $XMRIG_PATH"
mkdir build || handle_error "Не удалось создать директорию build"
cd build || handle_error "Не удалось перейти в директорию build"
cmake .. || handle_error "Не удалось выполнить cmake"
make || handle_error "Не удалось выполнить make"

# Создание файла конфигурации 
echo -e "${BLUE}Создание файла конфигурации...${NC}"
mkdir -p "$XMRIG_PATH/logs" || handle_error "Не удалось создать директорию логов"
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

# Настройка автоматической очистки логов
echo -e "${BLUE}Настройка автоматической очистки логов...${NC}"
cat << EOF > /usr/local/bin/clear_xmrig_logs.sh
#!/bin/bash
if [ -f "$LOG_FILE" ]; then
    echo "" > "$LOG_FILE"
fi
EOF
chmod +x /usr/local/bin/clear_xmrig_logs.sh || handle_error "Не удалось сделать скрипт очистки логов исполняемым"

# Настройка cron для удаления логов
(crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/clear_xmrig_logs.sh") | crontab - || handle_error "Не удалось добавить задачу в cron"

# Защита файлов и службы от удаления
echo -e "${BLUE}Настройка защиты от удаления...${NC}"
chattr +i /etc/systemd/system/xmrig.service || handle_error "Не удалось защитить службу от удаления"
chattr +i "$XMRIG_PATH/build/config.json" || handle_error "Не удалось защитить конфигурационный файл от удаления"
chattr +i "$XMRIG_PATH/build/xmrig" || handle_error "Не удалось защитить бинарный файл от удаления"

# Создание скрипта мониторинга
echo -e "${BLUE}Создание скрипта мониторинга...${NC}"
cat << EOF > "$MONITOR_SCRIPT"
#!/bin/bash

if [ ! -f "/etc/systemd/system/xmrig.service" ] || [ ! -f "$XMRIG_PATH/build/xmrig" ]; then
    echo "${RED}XMRig удалён, восстанавливаем...${NC}"
    bash $0
fi
EOF
chmod +x "$MONITOR_SCRIPT" || handle_error "Не удалось сделать скрипт мониторинга исполняемым"

# Добавление скрипта мониторинга в cron
(crontab -l 2>/dev/null; echo "* * * * * $MONITOR_SCRIPT") | crontab - || handle_error "Не удалось добавить задачу мониторинга в cron"

# Включение и запуск службы
echo -e "${BLUE}Включение и запуск службы XMRig...${NC}"
systemctl daemon-reload || handle_error "Не удалось перезагрузить демоны systemd"
systemctl enable xmrig.service || handle_error "Не удалось включить службу XMRig"
systemctl start xmrig.service || handle_error "Не удалось запустить службу XMRig"

# Завершение установки
echo -e "${GREEN}Установка завершена! XMRig работает в фоновом режиме.${NC}"
echo -e "${GREEN}Для проверки статуса используйте: sudo systemctl status xmrig.service${NC}"
