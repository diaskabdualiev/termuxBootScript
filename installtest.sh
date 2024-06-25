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

        # Запись изменений в основной скрипт
        sed -i "s/^REMOTE_PORT=.*$/REMOTE_PORT=$new_remote_port/" camerafrpc.sh
        sed -i "s/^NAME=.*$/NAME=\"$new_name\"/" camerafrpc.sh

        echo "Переменные изменены и сохранены в camerafrpc.sh"
    else
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

echo "Установка и настройка завершены"
