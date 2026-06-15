# OpenTelemetry Observability Stack

A complete observability stack built with Docker Compose, featuring **Prometheus**, **Loki**, and **Tempo** for comprehensive metrics, logs, and distributed tracing.

<img width="796" height="496" alt="sys" src="https://github.com/user-attachments/assets/1ea24d09-323c-49f8-8ebf-bc6ddd5e630e" />


## 📁 Project Structure

```
opentelemetrycode/
├── compose/                          # Docker Compose orchestration
│   ├── compose.yaml                 # Main compose file (includes observability stack)
│   ├── compose.observability.yaml   # Observability services definitions
│   ├── prometheus.yaml              # Prometheus configuration (metrics scraping, retention)
│   ├── loki-config.yaml             # Loki configuration (log pipelines, storage)
│   ├── tempo-config.yaml            # Tempo configuration (trace ingestion, storage)
│   ├── grafana-datasources.yaml     # Grafana datasource auto-provisioning
│   └── test_scripts/                # Validation and testing scripts
│       ├── validate-loki.sh         # Test Loki log ingestion and querying
│       ├── validate-tempo.sh        # Test Tempo trace ingestion and storage
│       ├── validate-grafana.sh      # Test Grafana and datasource connectivity
│       ├── generate-traffic.sh      # Generate sample observability data
│       ├── cleanup-loki.sh          # Remove test data from Loki
│       └── loki-promql-queries.md   # Example PromQL and LogQL queries
├── section-setup/                    # Deployment guides and lab instructions
│   ├── INDEX.md                     # Guide index
│   ├── lab-setup.md                 # Initial setup instructions
│   ├── lab-deploy-prometheus.md     # Prometheus deployment guide
│   ├── lab-deploy-loki.md           # Loki deployment guide
│   ├── lab-deploy-tempo.md          # Tempo deployment guide
│   ├── lab-deploy-grafana.md        # Grafana deployment guide
│   └── lab-deploy-application.md    # Application deployment guide
├── README.md                         # This file
└── .git/                             # Git repository
```

## 🚀 Quick Start

### Prerequisites

- **Docker** and **Docker Compose** installed
- Port availability: 3000 (Grafana), 9090 (Prometheus), 3100 (Loki), 3200 (Tempo)

### Start the Observability Stack

```bash
cd compose
docker-compose up -d
```

## 📊 Observability Components

### Prometheus (Metrics)
- **Image:** `prom/prometheus:v3.9.1`
- **Port:** `9090`
- **Function:** Time-series metrics database and monitoring
- **Retention:** 15 days
- **URL:** http://localhost:9090

### Loki (Logs)
- **Image:** `grafana/loki:3.6.6`
- **Port:** `3100`
- **Function:** Log aggregation and querying system
- **URL:** http://localhost:3100 (API endpoint)

### Tempo (Distributed Traces)
- **Image:** `grafana/tempo:2.10.1`
- **Port:** `3200`
- **Function:** Distributed tracing backend for trace storage and querying
- **URL:** http://localhost:3200 (API endpoint)

### Grafana (Visualization)
- **Image:** `grafana/grafana:latest`
- **Port:** `3000`
- **Function:** Unified dashboard and visualization platform
- **URL:** http://localhost:3000
- **Features:**
  - Anonymous access enabled (no login required)
  - Auto-provisioned datasources (Prometheus, Loki, Tempo)
  - Trace-to-logs and trace-to-metrics correlation
  - Service map visualization
- **Configuration:** [grafana-datasources.yaml](compose/grafana-datasources.yaml)

## 🧪 Testing & Validation

Use the provided test scripts to validate your observability stack:

```bash
cd compose/test_scripts

# Validate each component
./validate-loki.sh        # Test Loki connectivity and log storage
./validate-tempo.sh       # Test Tempo connectivity and trace ingestion
./validate-grafana.sh     # Test Grafana and verify datasource configuration

# Additional testing
./generate-traffic.sh     # Generate sample data for testing
./cleanup-loki.sh         # Clean up test data from Loki
```

Refer to `loki-promql-queries.md` for example PromQL and LogQL queries.

## 🔧 Configuration

Each component has a dedicated configuration file:

- **prometheus.yaml** — Scrape targets, job definitions, and alerting rules
- **loki-config.yaml** — Log ingestion pipeline and retention policies
- **tempo-config.yaml** — Trace ingestion and backend storage

## 📚 Lab Guides

See [section-setup/](section-setup/INDEX.md) for step-by-step deployment and configuration guides.




