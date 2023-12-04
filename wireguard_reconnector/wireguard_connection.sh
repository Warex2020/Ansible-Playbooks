#!/bin/sh

# Configuration variables
VPN_SERVER_IP="10.66.66.1"
MAX_NOTIFICATIONS=5
EMAIL_FROM="root <mail@junix.de>"
EMAIL_TO="wireguard@junix.de"
COUNTER_FILE="/tmp/wireguard_connection_counter.txt"
HOSTNAME=$(hostname)

# Initialize or read the counter
if [ ! -f $COUNTER_FILE ]; then
    echo "0" > $COUNTER_FILE
fi
COUNTER=$(cat $COUNTER_FILE)

send_email() {
    SUBJECT="$HOSTNAME: $1"
    MESSAGE=$2

    echo "From: $EMAIL_FROM" > /tmp/mail.txt
    echo "To: $EMAIL_TO" >> /tmp/mail.txt
    echo "Subject: $SUBJECT" >> /tmp/mail.txt
    echo "Content-Type: text/html" >> /tmp/mail.txt
    echo >> /tmp/mail.txt
    echo "$MESSAGE" >> /tmp/mail.txt
    sendmail -t < /tmp/mail.txt
}

# Check the connection and perform the ping test
PING_LOG=$(ping -c 5 $VPN_SERVER_IP)
PING_SUCCESS=$?
IFCONFIG_LOG=$(ifconfig wg0)

# Check the WireGuard connection
if [ $PING_SUCCESS -ne 0 ]; then
    # Connection failed
    echo "Verbindung zu $VPN_SERVER_IP verloren, starte Wireguard neu..."
    systemctl restart wg-quick@wg0

    COUNTER=$((COUNTER+1))
    echo $COUNTER > $COUNTER_FILE

    if [ $COUNTER -eq 2 ] && [ $COUNTER -le $MAX_NOTIFICATIONS ]; then
        STATUS=$(systemctl status wg-quick@wg0 | sed 's/● //g' | sed 's/SUCCESS/<span style="color: green;">SUCCESS<\/span>/')
        STATUS=$(echo "$STATUS" | sed 's/active/<span style="color: green;">active<\/span>/')
        STATUS=$(echo "$STATUS" | sed -E 's/(failed|exited|dead|inactive)/<span style="color: red;">\1<\/span>/')

        MESSAGE="<html><body>"
        MESSAGE="${MESSAGE}<h2 style='color: red;'>Wireguard Verbindung abgebrochen</h2>"
        MESSAGE="${MESSAGE}<p><strong>Status:</strong></p><pre>${STATUS}</pre>"
        MESSAGE="${MESSAGE}<p><strong>Versuch:</strong> $COUNTER von $MAX_NOTIFICATIONS</p>"
        MESSAGE="${MESSAGE}<p><strong>Ping Log:</strong></p><pre>${PING_LOG}</pre>"
        MESSAGE="${MESSAGE}<p><strong>ifconfig wg0:</strong></p><pre>${IFCONFIG_LOG}</pre>"
        MESSAGE="${MESSAGE}</body></html>"

        send_email "Wireguard Verbindung abgebrochen (Versuch $COUNTER von $MAX_NOTIFICATIONS)" "$MESSAGE"
    fi
else
    if [ $COUNTER -gt 0 ]; then
        echo "0" > $COUNTER_FILE
        MESSAGE="<html><body>"
        MESSAGE="${MESSAGE}<h2 style='color: green;'>Wireguard Verbindung erfolgreich wiederhergestellt</h2>"
        MESSAGE="${MESSAGE}<p>Die Verbindung zu Wireguard wurde erfolgreich wiederhergestellt.</p>"
        MESSAGE="${MESSAGE}</body></html>"

        send_email "Wireguard Verbindung erfolgreich wiederhergestellt" "$MESSAGE"
    fi
fi
