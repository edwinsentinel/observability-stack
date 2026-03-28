#!/bin/bash
set -e

PROM_VERSION="2.53.1"
PROM_USER="prometheus"

sudo apt-get update
sudo apt-get install -y wget curl tar apt-transport-https software-properties-common

if ! id "${PROM_USER}" >/dev/null 2>&1; then
  sudo useradd --no-create-home --shell /usr/sbin/nologin ${PROM_USER}
fi

sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

if [ ! -f /usr/local/bin/prometheus ]; then
  cd /tmp
  wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
  tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

  sudo cp prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
  sudo cp prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
  sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/consoles /etc/prometheus
  sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/console_libraries /etc/prometheus
fi

sudo chown -R ${PROM_USER}:${PROM_USER} /etc/prometheus /var/lib/prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

sudo tee /etc/prometheus/prometheus.yml > /dev/null <<'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporters'
    static_configs:
      - targets:
          - 'web01:9100'
          - 'app01:9100'
          - 'db01:9100'
          - 'mc01:9100'
          - 'rmq01:9100'
EOF

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=${PROM_USER}
Group=${PROM_USER}
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl restart prometheus

# Install Grafana
if [ ! -f /etc/apt/sources.list.d/grafana.list ]; then
  wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg
  echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
fi

sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl enable grafana-server
sudo systemctl restart grafana-server