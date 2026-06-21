# Project: OpenTelemetry Collector Overview

## What the OpenTelemetry Collector is

The OpenTelemetry Collector is a standalone service that sits between your applications and your observability backends. Instead of making each application send telemetry directly to multiple systems, the collector receives data once and then routes, transforms, and exports it.

In this project, the collector is the central point that receives:

- traces
- metrics
- logs

and forwards them to:

- Tempo for traces
- Prometheus for metrics
- Loki for logs

---

## Why use a collector?

Using a collector gives you several benefits:

- **Centralized configuration**: one place to manage telemetry settings
- **Better operational control**: batching, retries, limits, and filtering
- **Simpler application code**: apps do not need to know every backend destination
- **Cleaner scaling**: you can scale the collector independently from application services
- **Consistency**: all telemetry follows the same pipeline rules

A common analogy is that the collector is the "traffic control center" for observability data.

---

## Core collector architecture

The collector is built from four main concepts:

### 1. Receivers
Receivers accept telemetry from outside the collector.

In this repo, the collector uses OTLP receivers:

- OTLP/gRPC on port `4317`
- OTLP/HTTP on port `4318`

These are the entry points where your app or test tools send data.

### 2. Processors
Processors modify or enrich telemetry before it is exported.

In this setup, the collector uses:

- `memory_limiter` to avoid excessive memory use
- `batch` to group items together for efficiency

This reduces network overhead and makes the pipeline more stable under load.

### 3. Exporters
Exporters send telemetry to destination systems.

In this repo the collector exports to:

- Tempo for traces
- Prometheus for metrics
- Loki for logs

### 4. Service pipelines
Service pipelines define how data flows:

- traces pipeline
- metrics pipeline
- logs pipeline

Each pipeline lists:

- which receiver accepts the data
- which processors apply to it
- which exporter sends it out

---

## How the data flow works in this project

The flow looks like this:

1. The application or a manual test request sends telemetry to the collector.
2. The collector receives the telemetry using OTLP.
3. The collector applies processors such as batching and memory protection.
4. The collector sends the data to Tempo, Prometheus, or Loki.
5. Grafana reads from those backends so you can inspect traces, metrics, and logs.

A simplified view:

```text
Application -> OTLP receiver -> processor(s) -> exporter(s) -> backend
```

---

## Collector config in this repository

The main collector configuration is stored in [compose/otel-collector-config.yaml](compose/otel-collector-config.yaml).

The key parts are:

### Receivers
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
```

This tells the collector to listen for OTLP data on both gRPC and HTTP.

### Processors
```yaml
processors:
  batch:
    timeout: 10s
    send_batch_size: 1024
  memory_limiter:
    check_interval: 1s
    limit_mib: 512
```

These settings improve efficiency and protect the collector from running out of memory.

### Exporters
```yaml
exporters:
  otlp/tempo:
    endpoint: tempo:4317
  prometheus:
    endpoint: 0.0.0.0:8889
  otlphttp/loki:
    endpoint: http://loki:3100/otlp
```

These tell the collector where to send each signal type.

### Pipelines
```yaml
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [otlp/tempo]
```

This means:

- traces come in through OTLP
- they are processed
- they are exported to Tempo

The same pattern is used for metrics and logs.

---

## Why the collector is important for this course

The collector is important because it teaches the difference between:

- sending telemetry directly from an app
- routing telemetry through a dedicated pipeline

In real systems, collectors are often used to:

- add metadata
- deduplicate signals
- enforce sampling rules
- secure or transform data before it reaches backend systems

---

## How to test the collector

### 1. Start the stack

From the compose folder:

```bash
docker compose -f compose.yaml up -d
```

### 2. Send a trace request

Use the collector endpoint:

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

### 3. Check that data arrived

- In Grafana, open Explore and inspect Tempo
- In Prometheus, check collector metrics
- In the collector logs, confirm that telemetry was received and exported

---

## Common troubleshooting tips

### Collector not receiving telemetry
Check that:

- port `4317` or `4318` is exposed correctly
- the app is sending to the correct URL
- the collector container is running

### Prometheus config fails
If Prometheus reports a YAML parsing error, check:

- indentation
- list formatting
- missing colons or quotes

### `200 OK` but `partialSuccess`
This usually means the HTTP request was accepted, but some items in the body were not fully valid. Check:

- trace/span ID formats
- timestamp values
- JSON structure

### No traces visible in Tempo
Check that:

- the pipeline is configured correctly
- the collector has enough time to batch data
- the logs do not show exporter errors

---

## Summary

The OpenTelemetry Collector is the bridge between application telemetry and observability backends. It receives data, processes it, and sends it onward using well-defined pipelines. In this project, it plays a central role in making traces, metrics, and logs visible and queryable in the monitoring stack.
