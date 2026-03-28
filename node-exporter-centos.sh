#!/bin/bash
set -e

NODE_EXPORTER_VERSION="1.8.2"
NODE_EXPORTER_USER="node_exporter"

if ! id "${NODE_EXPORTER_USER}" >/dev/null 2>&1; then
  sudo useradd --no-create-home --shell /sbin/nologin ${NODE_EXPORTER_USER}
fi

if [ ! -f /usr/local/bin/node_exporter ]; then
  cd /tmp
  curl -LO https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
  tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
  sudo cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
  sudo chown ${NODE_EXPORTER_USER}:${NODE_EXPORTER_USER} /usr/local/bin/node_exporter
fi

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=${NODE_EXPORTER_USER}
Group=${NODE_EXPORTER_USER}
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl restart node_exporter

if command -v firewall-cmd >/dev/null 2>&1; then
  sudo systemctl enable --now firewalld || true
  sudo firewall-cmd --permanent --add-port=9100/tcp || true
  sudo firewall-cmd --reload || true
fi