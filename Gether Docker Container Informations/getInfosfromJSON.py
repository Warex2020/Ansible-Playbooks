import json
import os
import yaml

# Pfad zur JSON-Datei
json_file = './Logs/Docker-Containers_10.66.66.5.json'

# Extrahiere die IP-Adresse aus dem Dateinamen
ip_address = os.path.basename(json_file).split('_')[-1].rsplit('.', 1)[0]


# Hauptverzeichnis für die Dockerfiles
output_dir = f'./dockerfiles/{ip_address}/'

# Stelle sicher, dass das Hauptverzeichnis existiert
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Lese JSON-Datei
with open(json_file, 'r') as file:
    data = json.load(file)

# Durchlaufe jedes JSON-Objekt in der Datei
for json_str in data:
    # Parse den String als JSON
    container_list = json.loads(json_str)
    
    # Erstelle Unterordner und docker-compose.yml für jeden Container
    for container in container_list:
        container_name = container['Name'].strip('/')

        # Erstelle den Unterordner für den Container
        container_dir = os.path.join(output_dir, container_name)
        if not os.path.exists(container_dir):
            os.makedirs(container_dir)

        # Docker-Compose-Service-Definition
        service = {
            'image': container['Config']['Image'],
            'volumes': [f"{vol['Source']}:{vol['Destination']}" for vol in container.get('Mounts', [])],
            'environment': container.get('Config', {}).get('Env', [])
        }

        # Füge Ports hinzu, falls vorhanden
        ports = container['NetworkSettings']['Ports']
        if ports:
            service['ports'] = [f"{binding['HostPort']}:{port.split('/')[0]}" for port, bindings in ports.items() if bindings for binding in bindings]

        # Vorbereitung der Struktur für docker-compose
        docker_compose = {
            'version': '3',
            'services': {
                container_name: service
            }
        }

        # Speichere die docker-compose.yml im Unterordner
        compose_file_path = os.path.join(container_dir, 'docker-compose.yml')
        with open(compose_file_path, 'w') as file:
            yaml.dump(docker_compose, file, default_flow_style=False)

        print(f"docker-compose.yml für {container_name} erstellt: {compose_file_path}")
