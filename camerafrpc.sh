#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock

LOG_DIR=~/logs
LOG_FILE=$LOG_DIR/camerafrpc.log
WLAN_INTERFACE=wlan0

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

# Проверка устройств с открытым портом RTSP (554)
check_rtsp_port() {
    nmap -p 554 --open $wlan_ip > $LOG_DIR/nmap_output.log 2>&1

    if grep -q "554/tcp open rtsp" $LOG_DIR/nmap_output.log; then
        log "Устройство с открытым портом RTSP найдено."
        termux-toast "Устройство с открытым портом RTSP найдено."
        termux-notification --title "Успех" --content "Устройство с открытым портом RTSP найдено."
    else
        log "Устройство с открытым портом RTSP не найдено."
        termux-toast "Устройство с открытым портом RTSP не найдено."
        termux-notification --title "Ошибка" --content "Устройство с открытым портом RTSP не найдено."
    fi
}

# Основной цикл
while true; do
    if check_access_point; then
        check_rtsp_port
    fi
    sleep 60
done
