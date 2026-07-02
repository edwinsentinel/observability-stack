import { metrics } from '@opentelemetry/api';

// Create a named meter for frontend translation metrics.
// The meter name and version help identify where metrics originate.
const meter = metrics.getMeter('translation-frontend', '1.0.0');

// Counter for the total number of translation requests received by the frontend.
export const translationRequestsCounter = meter.createCounter(
  'translation.requests.total',
  { description: 'Total translation requests' },
);

// Counter for the total number of translation jobs pushed into the queue.
export const jobsEnqueuedCounter = meter.createCounter(
  'translation.jobs.enqueued.total',
  { description: 'Total translation jobs enqueued' },
);

// Histogram for measuring the duration of translation request handling in milliseconds.
export const requestDuration = meter.createHistogram(
  'translation.request.duration',
  { description: 'Translation request processing time', unit: 'ms' },
);

// Counter for the total number of validation errors encountered during translation requests.
export const validationErrorsCounter = meter.createCounter(
  'translation.validation.errors.total',
  { description: 'Translation validation errors' },
);
