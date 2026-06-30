// instrumentation.ts
// Sets up OpenTelemetry for the translation frontend application.
// Exports traces, metrics, and logs to an OTLP receiver (collector) using HTTP.

import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { WinstonInstrumentation } from '@opentelemetry/instrumentation-winston';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-http';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { OTLPLogExporter } from '@opentelemetry/exporter-logs-otlp-http';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { BatchLogRecordProcessor } from '@opentelemetry/sdk-logs';


// Create and configure the NodeSDK instance. This centralizes
// telemetry configuration (service name, exporters, readers, processors,
// and instrumentations) in one place and starts the SDK below.
const sdk = new NodeSDK({
  // Logical service name used in exported telemetry for identification.
  serviceName: 'translation-frontend',

  // Configure trace exporting to the collector's OTLP HTTP endpoint.
  traceExporter: new OTLPTraceExporter({
    // Collector receives traces on port 4318 under /v1/traces by default.
    url: 'http://otel-collector:4318/v1/traces',
  }),

  // Configure metrics using a periodic exporting reader.
  metricReader: new PeriodicExportingMetricReader({
    exporter: new OTLPMetricExporter({
      // Collector OTLP metrics endpoint.
      url: 'http://otel-collector:4318/v1/metrics',
    }),
    // How often (ms) to push metrics to the exporter. 10s chosen for demos.
    exportIntervalMillis: 10000,
  }),

  // Configure log exporting. We use a batch processor to buffer records
  // and send them in batches to the OTLP logs endpoint for efficiency.
  logRecordProcessors: [
    new BatchLogRecordProcessor(
      new OTLPLogExporter({
        // Collector OTLP logs endpoint.
        url: 'http://otel-collector:4318/v1/logs',
      }),
    ),
  ],

  // Enable automatic and framework-specific instrumentations.
  // - getNodeAutoInstrumentations(): common Node.js libs (HTTP, DNS, etc.)
  // - WinstonInstrumentation(): captures structured logs produced by Winston
  instrumentations: [
    getNodeAutoInstrumentations(),
    new WinstonInstrumentation(),
  ],
});

// Start the SDK to initialize instrumentations and begin exporting data.
sdk.start();
