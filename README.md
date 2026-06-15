# OpenTelemetry Observability Stack

A complete observability stack built with Docker Compose, featuring **Prometheus**, **Loki**, and **Tempo** for comprehensive metrics, logs, and distributed tracing.

## 📁 Project Structure

```
├── compose/                    # Docker Compose setup for observability stack
│   ├── compose.yaml           # Main orchestration file
│   ├── compose.observability.yaml  # Observability stack services
│   ├── prometheus.yaml        # Prometheus metrics configuration
│   ├── loki-config.yaml       # Loki logging configuration
│   ├── tempo-config.yaml      # Tempo distributed tracing configuration
│   └── test_scripts/          # Validation and testing scripts
├── section-setup/             # Lab guides and deployment instructions
└── README.md                  # This file
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
./validate-loki.sh        # Test Loki connectivity
./generate-traffic.sh     # Generate sample data
./cleanup-loki.sh         # Clean up test data
```

Refer to `loki-promql-queries.md` for example PromQL and LogQL queries.

## 🔧 Configuration

Each component has a dedicated configuration file:

- **prometheus.yaml** — Scrape targets, job definitions, and alerting rules
- **loki-config.yaml** — Log ingestion pipeline and retention policies
- **tempo-config.yaml** — Trace ingestion and backend storage

## 📚 Lab Guides

See [section-setup/](section-setup/INDEX.md) for step-by-step deployment and configuration guides.




