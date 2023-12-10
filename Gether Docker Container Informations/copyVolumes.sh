#!/bin/bash

# Pfad zu den Docker-Containern auf dem Client
CLIENT_DOCKER_PATH="./dockerfiles/"

echo "Starte das Herunterladen der Volumes..."

# Durchlaufe alle Host-IP-Ordner in CLIENT_DOCKER_PATH
for host_dir in $CLIENT_DOCKER_PATH*; do
    if [ -d "$host_dir" ]; then
        TARGET_HOST=$(basename "$host_dir")
        echo "Arbeite am Host: $TARGET_HOST"

        # Durchlaufen der Container-Verzeichnisse für diesen Host
        for container_dir in $host_dir/*; do
            if [ -d "$container_dir" ]; then
                container_name=$(basename "$container_dir")
                echo "  Bearbeite Container: $container_name"

                # Verwende SSH, um die Docker-Inspektion auf dem Zielhost durchzuführen
                # und die Pfade der Volumes zu ermitteln
                echo "    Ermittle Volumes-Pfade für Container $container_name..."
                volume_paths=$(ssh "$TARGET_HOST" "docker inspect $container_name --format '{{ range .Mounts }}{{ .Source }}:{{ .Destination }}{{ end }}'")

                # Trenne die Source- und Destination-Pfade
                IFS=':' read -ra ADDR <<< "$volume_paths"
                source_path="${ADDR[0]}"
                destination_path="${ADDR[1]}"

                # Kopiere das Volume-Verzeichnis vom Zielhost in den Container-Ordner auf dem Client
                echo "    Kopiere Volumes von $source_path zu $container_dir$destination_path..."
                rsync -avz --progress "$TARGET_HOST:$source_path/" "$container_dir$destination_path/"
            fi
        done
    fi
done

echo "Volume-Download abgeschlossen."
