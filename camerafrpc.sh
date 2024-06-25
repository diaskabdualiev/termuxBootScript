#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock

# Переменные конфигурации
LOG_DIR=$HOME/logs
LOG_FILE=$LOG_DIR/camerafrpc.log
FRPC_CONFIG=$HOME/frpc.ini
WLAN_INTERFACE=wlan0
SERVER_ADDR="54.224.210.175"
SERVER_PORT=7000
REMOTE_PORT=6100  # Эта переменная может быть изменена через setup.sh
NAME=shecker6100  # Эта переменная может быть изменена через setup.sh

# Создание директории для логов
mkdir -p $LOG_DIR

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a $LOG_FILE
}

# Проверка интерфейса WLAN и состояния точки доступа
check_access_point() {
    ifconfig > $LOG_DIR/ifconfig_output.log 2>&1
    wlan_ip=$(ifconfig | grep -A 1 "$WLAN_INTERFACE" | grep 'inet ' | awk '{ print $2 }')

    log "WLAN IP: $wlan_ip"

    if [ -z "$wlan_ip" ]; then
        log "Точка доступа не запущена. IP-адрес не найден."
        termux-toast "Точка доступа не запущена. IP-адрес не найден."
        termux-notification --title "Ошибка" --content "Точка доступа не запущена. IP-адрес не найден."
        return 1
    fi

    third_octet=$(echo $wlan_ip | cut -d'.' -f3)

    if [ "$third_octet" -eq 0 ] || [ "$third_octet" -eq 1 ]; then
        log "Точка доступа не запущена. IP-адрес указывает на подключение к Wi-Fi."
        termux-toast "Точка доступа не запущена. Подключение к Wi-Fi."
        termux-notification --title "Ошибка" --content "Точка доступа не запущена. Подключение к Wi-Fi."
        return 1
    fi

    termux-toast "Точка доступа запущена. IP: $wlan_ip"
    termux-notification --title "Успех" --content "Точка доступа запущена. IP: $wlan_ip"
    return 0
}

# Проверка устройств с открытым портом RTSP (554) и запуск прокси-сервера
check_rtsp_port_and_start_proxy() {
    nmap -p 554 --open ${wlan_ip%.*}.0/24 > $LOG_DIR/nmap_output.log 2>&1

    open_rtsp_ip=$(grep -B 4 "554/tcp open  rtsp" $LOG_DIR/nmap_output.log | grep "Nmap scan report for" | awk '{ print $5 }' | head -n 1)

    if [ -n "$open_rtsp_ip" ]; then
        log "Устройство с открытым портом RTSP найдено: $open_rtsp_ip"
        termux-toast "Устройство с открытым портом RTSP найдено: $open_rtsp_ip"
        termux-notification --title "Успех" --content "Устройство с открытым портом RTSP найдено: $open_rtsp_ip"

        # Создание файла конфигурации frpc.ini
        cat <<EOF > $FRPC_CONFIG
[common]
server_addr = $SERVER_ADDR
server_port = $SERVER_PORT

[proxies]
name = "$NAME"
type = "tcp"
local_ip = "$open_rtsp_ip"
local_port = 554
remote_port = $REMOTE_PORT
EOF

        # Запуск frpc с конфигурацией и запись логов
        frpc -c $FRPC_CONFIG > $LOG_DIR/frpc.log 2>&1 &
        FRPC_PID=$!
        log "frpc запущен с PID: $FR
