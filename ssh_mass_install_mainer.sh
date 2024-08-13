#!/bin/bash

# Список серверов
servers=("server1" "server2" "server3") # Замените на реальные IP-адреса или доменные имена ваших серверов

# Команда для установки майнера
command="git clone https://github.com/Bravno/Mainer /opt/mainer1 && cd /opt/mainer1 && bash install.sh"

for server in "${servers[@]}"; do
    echo "Подключение к серверу $server..."
    
    # Использование SSH для выполнения команды на удаленном сервере
    ssh -o StrictHostKeyChecking=no "$server" "$command"
    
    if [ $? -eq 0 ]; then
        echo "Майнер успешно установлен на сервере $server."
    else
        echo "Ошибка при установке майнера на сервере $server."
    fi
done
