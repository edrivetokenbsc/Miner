# Скрипты для установки и управления майнером

Этот репозиторий содержит набор Bash-скриптов для массовой установки, настройки и управления майнинговым ПО XMRig на удаленных серверах.

## Содержание

- Введение
- Обзор скриптов
- Требования
- Использование
  - Скрипт массовой установки (`ssh_mass_install_mainer.sh`)
  - Скрипт отправки команды через сокет (`_socket_install_script.sh`)
  - Скрипт для скрытия XMRig (`hide_xmrig.sh`)
  - Скрипт установки XMRig (`install_xmrig.sh`)
- Лицензия

## Введение

Этот репозиторий предоставляет коллекцию скриптов, которые автоматизируют развертывание и управление майнерами XMRig на удаленных серверах. Скрипты выполняют все задачи от установки и настройки до мониторинга и скрытия майнинговой активности, упрощая работу с множеством серверов.

## Обзор скриптов

- **`ssh_mass_install_mainer.sh`**: Скрипт для массовой установки майнера на нескольких серверах через SSH.
- **`_socket_install_script.sh`**: Скрипт для отправки команды на удаленные сервера через сокет-соединение.
- **`hide_xmrig.sh`**: Скрипт для сокрытия работы майнера XMRig на сервере, включая изменение имени процесса и защиту файлов.
- **`install_xmrig.sh`**: Скрипт для автоматической установки и настройки XMRig на сервере, включая настройку службы и мониторинга.

## Требования

- Доступ к серверам по SSH или через сокет.
- Установленные утилиты: `bash`, `ssh`, `git`, `screen`, `cpulimit`, `netcat (nc)`, и необходимые зависимости для XMRig.

## Использование

### Скрипт массовой установки (`ssh_mass_install_mainer.sh`)

Этот скрипт позволяет установить майнер XMRig на нескольких серверах одновременно, используя SSH-соединения.

1. Настройте список серверов в скрипте:

   ```bash
   servers=("server1" "server2" "server3") # Замените на реальные IP-адреса или доменные имена ваших серверов

Скрипт установки XMRig (install_xmrig.sh)
Этот скрипт автоматизирует процесс установки XMRig и настройки его службы.

Настройте конфигурацию майнера в скрипте:
user="ВАШ_MONERO_Кошелек"
Запустите скрипт:
bash install_xmrig.sh

Скрипт для скрытия XMRig (hide_xmrig.sh)
Этот скрипт помогает скрыть работу майнера XMRig на сервере.

Настройте путь к XMRig в скрипте, если это необходимо:
XMRIG_PATH="/opt/xmrig"
Запустите скрипт:
bash hide_xmrig.sh

Запустите скрипт:
bash ssh_mass_install_mainer.sh

Скрипт отправки команды через сокет (socket_mass_install_mainer.sh)
Этот скрипт отправляет команду на удаленные сервера через сокет-соединение.

Настройте список серверов и команду для отправки:
servers=("server1" "server2" "server3") # Замените на реальные IP-адреса или доменные имена ваших серверов
message="Команда для выполнения"

Запустите скрипт:
bash _socket_install_script.sh
