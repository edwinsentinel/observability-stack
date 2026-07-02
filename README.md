# OpenTelemetry Observability Stack

A complete observability stack built with Docker Compose, featuring **Prometheus**, **Loki**, and **Tempo** for comprehensive metrics, logs, and distributed tracing.

<img width="796" height="496" alt="sys" src="https://github.com/user-attachments/assets/1ea24d09-323c-49f8-8ebf-bc6ddd5e630e" />


## 📁 Project Structure

```
opentelemetrycode/
├── compose/                          # Docker Compose orchestration and configs
│   ├── compose.app.yaml              # Application compose configuration
│   ├── compose.dev.yaml              # Development compose overrides
│   ├── compose.observability.yaml    # Observability stack compose definitions
│   ├── compose.prod.yaml             # Production compose overrides
│   ├── compose.yaml                  # Legacy/main compose file
│   ├── grafana-datasources.yaml     # Grafana datasource auto-provisioning
│   ├── loki-config.yaml             # Loki configuration (log pipelines, storage)
│   ├── prometheus.yaml              # Prometheus configuration (scraping jobs)
│   ├── otel-collector-config.yaml   # OpenTelemetry Collector config (receivers/exporters)
│   ├── tempo-config.yaml            # Tempo configuration (trace ingestion/storage)
│   └── test_scripts/                # Validation and testing scripts
│       ├── validate-loki.sh         # Test Loki connectivity and ingestion
│       ├── validate-tempo.sh        # Test Tempo ingestion and queries
│       ├── validate-grafana.sh      # Verify Grafana and datasources
│       ├── generate-traffic.sh      # Generate sample observability traffic
│       ├── cleanup-loki.sh          # Remove test data from Loki
│       └── loki-promql-qeries.md    # Example PromQL/LogQL queries (note filename as in repo)
├── app-versions/                     # Versioned application code and examples
│   └── code/                         # Application source and deployment manifests
│       ├── frontend/                 # Frontend app (translation UI)
│       ├── worker/                   # Background worker service
│       ├── compose.yml               # App-level compose for local testing
│       ├── compose.dev.yml
│       ├── compose.yml               # (additional compose variants)
│       ├── DEVELOPMENT.md            # Development notes
│       └── README.md                 # App-level README
├── section-setup/                    # Deployment guides and lab instructions
│   ├── INDEX.md
│   ├── project-setup.md
│   ├── project-deploy-application.md
│   ├── project-deploy-collector.md
│   ├── project-deploy-grafana.md
│   ├── project-deploy-loki.md
│   ├── project-deploy-prometheus.md
│   ├── project-deploy-tempo.md
│   ├── project-local-development.md
│   ├── project-metrics-auto.md
│   └── project-test-collector.md
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




