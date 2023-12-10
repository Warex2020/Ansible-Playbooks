#!/bin/bash

HOSTNAME=$(hostname)
EMAIL_FROM="${EMAIL_FROM:-default_sender@domain.com}"
EMAIL_TO="${EMAIL_TO:-default_recipient@domain.com}"

# Funktion zur Überprüfung des Status von Services
check_service_status() {
    SERVICE_NAME=$1
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo "<span style='color: green;'>Active</span>"
    else
        echo "<span style='color: red; font-weight: bold;'>Inactive</span>"
    fi
}

# Logwatch-Bericht
logwatch_report() {
    # Stellen Sie sicher, dass logwatch installiert ist
    if command -v logwatch &> /dev/null; then
        echo "<h2>Logwatch Report</h2>"
        echo "<pre>$(logwatch --output stdout --format text --range 'yesterday')</pre>"
    else
        echo "<p>logwatch ist nicht installiert. Bitte installieren Sie logwatch, um Systemlogberichte zu erhalten.</p>"
    fi
}

# Überprüfung und Anzeige des iptables-Status und der Regeln
iptables_info() {
    if iptables -L | grep -q 'Chain'; then
        echo "<span style='color: green;'>Active (Regeln sind gesetzt)</span><br>"
        echo "<pre>$(iptables -L)</pre>"
    else
        echo "<span style='color: red; font-weight: bold;'>Inactive (Keine Regeln gefunden)</span>"
    fi
}

# Docker-Statistiken
docker_stats() {
    if command -v docker &> /dev/null; then
        echo "<h2>Docker Container Auslastung</h2><pre>$(docker stats --no-stream)</pre>"
        echo "<h2>Aktive/Inaktive Docker Container</h2><pre>$(docker ps -a)</pre>"
        echo "<h2>Docker Container Laufzeiten</h2><pre>$(docker ps -a --format 'table {{.Names}}\t{{.Status}}')</pre>"
        echo "<h2>Kurze Auszüge aus den Docker Logs (letzten 20 Zeilen)</h2>"
        for container in $(docker ps -q); do
            container_name=$(docker inspect --format '{{ .Name }}' $container | sed 's/^\///')
            echo "<p>Logs für Container ${container} (${container_name}):</p><pre>$(docker logs $container | tail -n 20)</pre>"
        done
    else
        echo "<p>Docker ist nicht installiert.</p>"
    fi
}

# Netzwerkauslastung und Speedtest
network_info() {
    echo "<h2>Aktuelle Netzwerkauslastung</h2><pre>$(ifconfig)</pre>"
    echo "<h2>Speedtest</h2>"
    if command -v speedtest-cli &> /dev/null; then
        echo "<pre>$(speedtest-cli)</pre>"
    else
        echo "<p>speedtest-cli ist nicht installiert. Bitte installieren Sie speedtest-cli, um Netzwerkgeschwindigkeitstests durchzuführen.</p>"
    fi
}

# Auffälligkeiten
check_anomalies() {
    echo "<h2>Auffälligkeiten</h2>"
    echo "<h3>Interface-Fehler</h3><pre>$(ifconfig | grep -E 'RX errors|TX errors')</pre>"
    echo "<h3>Speicherplatz</h3>"
    disk_space=$(df -h | grep -vE '^Filesystem|tmpfs|cdrom')
    if echo "$disk_space" | grep -q '100%'; then
        echo "<p><strong>Achtung:</strong> Ein oder mehrere Laufwerke sind voll.</p>"
    fi
    echo "<pre>$disk_space</pre>"
}

# E-Mail Nachricht erstellen
MESSAGE="<html><body>"
MESSAGE="${MESSAGE}<h1>Serverbericht für ${HOSTNAME}</h1>"
MESSAGE="${MESSAGE}<h2>Status wichtiger Services</h2>"
MESSAGE="${MESSAGE}<p>Wireguard: $(check_service_status wg-quick@wg0)</p>"
MESSAGE="${MESSAGE}<p>UFW: $(check_service_status ufw)</p>"
MESSAGE="${MESSAGE}<p>IPTABLES: $(iptables_info)</p>"
MESSAGE="${MESSAGE}<p>SSHD: $(check_service_status sshd)</p>"
MESSAGE="${MESSAGE}$(docker_stats)"
MESSAGE="${MESSAGE}$(network_info)"
MESSAGE="${MESSAGE}$(check_anomalies)"
MESSAGE="${MESSAGE}$(logwatch_report)"
MESSAGE="${MESSAGE}</body></html>"

# Send the email using sendmail
echo "From: $EMAIL_FROM" > /tmp/mail.txt
echo "To: $EMAIL_TO" >> /tmp/mail.txt
echo "Subject: =?UTF-8?B?$(echo "Serverbericht für ${HOSTNAME}" | base64)?=" >> /tmp/mail.txt
echo "Content-Type: text/html" >> /tmp/mail.txt
echo >> /tmp/mail.txt
echo "$MESSAGE" >> /tmp/mail.txt
sendmail -t < /tmp/mail.txt