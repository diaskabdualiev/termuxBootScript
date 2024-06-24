#!/bin/bash

# Установить необходимые пакеты
pkg install termux-api -y
pkg install net-tools -y
pkg install nmap -y
pkg install frp -y

# Тестирование установки Termux API
echo "Test api application"
termux-toast "Termux Api Installation test"
termux-vibrate -d 3000

# Функция переопределения переменных
redefine_variables() {
    read -p "Хотите изменить remotePort и name? (Y/N): " change_vars
    if [[ "$change_vars" == "Y" || "$change_vars" == "y" ]]; then
        read -p "Введите новый remotePort: " new_remote_port
        read -p "Введите новое имя: " new_name

        # Запись изменений в конфигурационный файл
        cat <<EOF > ./config.sh
#!/data/data/com.termux/files/usr/bin/sh

# Переменные конфигурации
LOG_DIR=~/logs
LOG_FILE=\$LOG_DIR/camerafrpc.log
FRPC_CONFIG=~/frpc.ini
WLAN_INTERFACE=wlan0
SERVER_ADDR="54.224.210.175"
SERVER_PORT=7000
REMOTE_PORT=$new_remote_port
NAME=$new_name
EOF

        echo "Переменные изменены и сохранены в config.sh"
    else
        cp ./config.sh.default ./config.sh
        echo "Используются переменные по умолчанию."
    fi
}

# Вызов функции переопределения переменных
redefine_variables

# Создание директории для автозапуска
echo "Создание директории для автозапуска"
mkdir -p ~/.termux/boot

# Копирование и установка прав для скрипта автозапуска
cp ./camerafrpc.sh ~/.termux/boot/camerafrpc.sh
chmod +x ~/.termux/boot/camerafrpc.sh

# Копирование файла конфигурации
cp ./config.sh ~/.termux/boot/config.sh
chmod +x ~/.termux/boot/config.sh

echo "Установка и настройка завершены"
