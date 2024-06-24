#!/bin/bash

# Установить необходимые пакеты
pkg install termux-api -y
pkg install net-tools -y
pkg install nmap -y
pkg install frpc -y

# Тестирование установки Termux API
echo "Test api application"
termux-toast "Termux Api Installation test"
termux-vibrate -d 3000

# Создание директории для автозапуска
echo "Создание директории для автозапуска"
mkdir -p ~/.termux/boot

# Копирование и установка прав для скрипта автозапуска
cp ./camerafrpc.sh ~/.termux/boot/camerafrpc.sh
chmod +x ~/.termux/boot/camerafrpc.sh

echo "Установка и настройка завершены"
