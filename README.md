# OpenTelemetry Observability Stack

This repository shows how to run a full observability setup with Docker Compose, including **Prometheus** for metrics, **Loki** for logs, **Tempo** for traces, **Grafana** for visualization, and the **OpenTelemetry Collector** for receiving and forwarding telemetry.

<img width="796" height="496" alt="sys" src="https://github.com/user-attachments/assets/1ea24d09-323c-49f8-8ebf-bc6ddd5e630e" />

## 📚 What this project covers

The workflow in this repo is:

1. Set up the observability backends
2. Use the code in [app-versions](app-versions) to run the frontend and worker services
3. Start the collector and application services
4. Verify metrics, logs, and traces in Grafana and Prometheus
5. Test telemetry manually with `curl` or Postman
6. Use development mode for faster iteration

---

## 🧭 Project structure

```text
opentelemetrycode/
├── app-versions/
│   ├── code/
│   │   ├── frontend/                 # Node/Express frontend app
│   │   └── worker/                   # Python worker app
│   └── README.md
├── compose/
│   ├── compose.yaml                  # Main entry point that includes the stack
│   ├── compose.observability.yaml    # Observability services
│   ├── compose.app.yaml              # Application services
│   ├── compose.dev.yaml              # Development overrides with hot reload
│   ├── compose.prod.yaml             # Production overrides with prebuilt images
│   ├── otel-collector-config.yaml    # Collector receiver/exporter pipeline config
│   ├── prometheus.yaml               # Prometheus scrape config
│   ├── loki-config.yaml              # Loki config
│   ├── tempo-config.yaml             # Tempo config
│   ├── grafana-datasources.yaml      # Grafana datasource provisioning
│   └── test_scripts/
│       ├── validate-loki.sh
│       ├── validate-tempo.sh
│       ├── validate-grafana.sh
│       ├── generate-traffic.sh
│       ├── cleanup-loki.sh
│       └── loki-promql-queries.md
├── section-setup/
│   ├── INDEX.md
│   ├── project-setup.md
│   ├── project-deploy-prometheus.md
│   ├── project-deploy-loki.md
│   ├── project-deploy-tempo.md
│   ├── project-deploy-grafana.md
│   ├── project-deploy-application.md
│   ├── project-local-development.md
│   └── project-test-collector.md
└── README.md
```

---

## ✅ Prerequisites

Before starting, make sure you have:

- Docker installed and running
- Docker Compose available
- Access to the following ports:
  - `3000` → Grafana
  - `9090` → Prometheus
  - `3100` → Loki
  - `3200` → Tempo
  - `4317` / `4318` → OTLP receiver ports

---

## 🚀 Step-by-step workflow

### 1) Start the observability stack

From the `compose` directory:

```bash
cd compose
docker compose -f compose.yaml up -d
```

This starts the backend services:

- Prometheus
- Loki
- Tempo
- Grafana
- OpenTelemetry Collector

### 2) Verify the services are running

Check container status:

```bash
docker compose -f compose.yaml ps
```

Open the UIs:

- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- Loki API: http://localhost:3100
- Tempo API: http://localhost:3200

### 3) Use the app source code from `app-versions`

The application code lives under [app-versions](app-versions), and this is the source you will use when working with the frontend and worker services.

- [app-versions/code/frontend](app-versions/code/frontend) contains the frontend service code
- [app-versions/code/worker](app-versions/code/worker) contains the worker service code

These folders are important because they are the codebases you will mount or build from when running the app in development or production mode.

### 4) Deploy the application

If the app services are part of the stack, start them with:

```bash
docker compose -f compose.yaml up -d
```

If you want to run the app separately, use the application compose file:

```bash
docker compose -f compose.app.yaml up -d
```

If you are working in development mode, use the code in [app-versions](app-versions) with the hot-reload setup:

```bash
docker compose -f compose.dev.yaml up --build
```

### 5) Test the collector

The collector listens for OTLP traffic on:

- `http://localhost:4318/v1/traces`
- `http://localhost:4317` for gRPC

You can send a sample trace with `curl` or Postman.

Example curl request:

```bash
curl -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
    "resourceSpans": [{
      "resource": {
        "attributes": [
          {"key": "service.name", "value": {"stringValue": "test-app"}}
        ]
      },
      "scopeSpans": [{
        "scope": {"name": "test-instrumentation"},
        "spans": [{
          "traceId": "11111111111111111111111111111111",
          "spanId": "2222222222222222",
          "name": "test-operation",
          "kind": 1,
          "startTimeUnixNano": "1710000000000000000",
          "endTimeUnixNano": "1710000001000000000",
          "status": {"code": 0}
        }]
      }]
    }]
  }'
```

Wait a few seconds, then check:

- Grafana → Explore → Tempo
- Prometheus → verify collector metrics

### 6) Validate with scripts

From the `compose/test_scripts` folder:

```bash
cd compose/test_scripts

./validate-loki.sh
./validate-tempo.sh
./validate-grafana.sh
./generate-traffic.sh
```

You can also use the example queries in [compose/test_scripts/loki-promql-queries.md](compose/test_scripts/loki-promql-queries.md).

### 7) Use development mode for fast iteration

For local development with hot reload, the app code from [app-versions](app-versions) is mounted into the containers so you can edit files locally and see changes quickly:

```bash
docker compose -f compose.dev.yaml up --build
```

This is especially useful when working with the frontend and worker code under [app-versions/code](app-versions/code).

### 8) Use production mode when needed

For the prebuilt image setup:

```bash
docker compose -f compose.prod.yaml up -d
```

---

## 📊 Key components

### Prometheus
- Port: `9090`
- Purpose: scrape and store metrics
- URL: http://localhost:9090

### Loki
- Port: `3100`
- Purpose: store and query logs
- URL: http://localhost:3100

### Tempo
- Port: `3200`
- Purpose: store and query distributed traces
- URL: http://localhost:3200

### Grafana
- Port: `3000`
- Purpose: dashboards and data source exploration
- URL: http://localhost:3000

### OpenTelemetry Collector
- Ports: `4317`, `4318`, `8889`
- Purpose: receive OTLP data and forward it to backend systems

---

## 🧪 Suggested validation flow

1. Start the stack
2. Verify dashboards in Grafana
3. Send a sample trace to the collector
4. Confirm metrics appear in Prometheus
5. Confirm logs appear in Loki
6. Confirm traces appear in Tempo

---

## 📘 Learning guides

The step-by-step projects  instructions are in [section-setup/INDEX.md](section-setup/INDEX.md).

The main lab sequence is:

- [section-setup/project-setup.md](section-setup/project-setup.md)
- [section-setup/project-deploy-prometheus.md](section-setup/project-deploy-prometheus.md)
- [section-setup/project-deploy-loki.md](section-setup/project-deploy-loki.md)
- [section-setup/project-deploy-tempo.md](section-setup/project-deploy-tempo.md)
- [section-setup/project-deploy-grafana.md](section-setup/project-deploy-grafana.md)
- [section-setup/project-deploy-application.md](section-setup/project-deploy-application.md)
- [section-setup/project-local-development.md](section-setup/project-local-development.md)
- [section-setup/project-test-collector.md](section-setup/project-test-collector.md)
- [section-setup/project-collector-guide.md](section-setup/project-collector-guide.md)

---

## 🛠️ Troubleshooting tips

- If a service does not start, check `docker compose ps`
- If Prometheus fails to load, verify the YAML indentation and config syntax
- If traces do not appear, wait a few seconds for batching and check the collector logs
- If Grafana shows missing data sources, re-check the provisioning file


