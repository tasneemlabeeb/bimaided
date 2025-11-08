#!/bin/bash

# Find correct Traefik entrypoint names and fix routing

SERVER_IP="72.60.222.97"
SERVER_USER="root"
export SSHPASS="lWV,S'8A+&grKvQlQ,7E"

echo "🔍 Finding Traefik entrypoint configuration..."
echo ""

sshpass -e ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
    echo "1️⃣ Checking Traefik static configuration..."
    docker exec coolify-proxy cat /etc/traefik/traefik.yaml 2>/dev/null || \
    docker exec coolify-proxy cat /etc/traefik/traefik.yml 2>/dev/null || \
    docker exec coolify-proxy cat /traefik.yaml 2>/dev/null || \
    docker exec coolify-proxy cat /traefik.yml 2>/dev/null || \
    echo "Traefik config not found in standard location"
    
    echo ""
    echo "2️⃣ Checking running Traefik configuration..."
    docker exec coolify-proxy traefik version
    
    echo ""
    echo "3️⃣ Inspecting Traefik container for command/args..."
    docker inspect coolify-proxy | grep -A 20 '"Cmd"'
    
    echo ""
    echo "4️⃣ Checking for existing working containers with Traefik labels..."
    docker ps --format '{{.Names}}' | while read container; do
        labels=$(docker inspect $container --format '{{range $key, $value := .Config.Labels}}{{if eq $key "traefik.http.routers"}}{{$key}}={{$value}}{{end}}{{end}}' 2>/dev/null)
        if [ ! -z "$labels" ]; then
            echo "Container: $container"
            docker inspect $container --format '{{range $key, $value := .Config.Labels}}{{if or (eq (printf "%.7s" $key) "traefik") (eq (printf "%.7s" $key) "coolify")}}  {{$key}}={{$value}}{{println}}{{end}}{{end}}' | head -20
            echo ""
        fi
    done
ENDSSH
