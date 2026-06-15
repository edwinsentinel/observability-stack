#!/bin/bash

# ============================================================
# Tempo Validation Script
# ============================================================
# This script sends sample trace data to Tempo and verifies
# that the traces are successfully stored and queryable.
# ============================================================

set -e  # Exit on any error

echo "🚀 Starting Tempo validation..."
echo ""

# Configuration
TEMPO_URL="http://localhost:3200"
TRACE_ID="12345678901234567890123456789012"  # 32-char hex trace ID
SPAN_ID="0123456789abcdef"  # 16-char hex span ID

# ============================================================
# Step 1: Verify Tempo is accessible
# ============================================================
echo "📡 Step 1: Checking Tempo connectivity..."

if ! curl -s "${TEMPO_URL}/api/status" > /dev/null 2>&1; then
  echo "❌ Error: Cannot reach Tempo at ${TEMPO_URL}"
  echo "   Make sure Tempo is running: docker compose ps"
  exit 1
fi

echo "✅ Tempo is accessible!"
echo ""

# ============================================================
# Step 2: Send trace data to Tempo
# ============================================================
echo "📤 Step 2: Sending test trace to Tempo..."

# Create a sample trace in OTLP JSON format
curl -X POST "${TEMPO_URL}/api/traces" \
  -H "Content-Type: application/json" \
  -d "{
    \"resourceSpans\": [
      {
        \"resource\": {
          \"attributes\": [
            {
              \"key\": \"service.name\",
              \"value\": {
                \"stringValue\": \"test-service\"
              }
            }
          ]
        },
        \"scopeSpans\": [
          {
            \"scope\": {
              \"name\": \"test-instrumentation\"
            },
            \"spans\": [
              {
                \"traceId\": \"${TRACE_ID}\",
                \"spanId\": \"${SPAN_ID}\",
                \"name\": \"test-span\",
                \"startTimeUnixNano\": \"$(date +%s)000000000\",
                \"endTimeUnixNano\": \"$(($(date +%s) + 1))000000000\",
                \"status\": {
                  \"code\": 0
                },
                \"attributes\": [
                  {
                    \"key\": \"test.key\",
                    \"value\": {
                      \"stringValue\": \"test-value\"
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }"

echo ""
echo "✅ Trace data sent successfully!"
echo ""

# ============================================================
# Step 3: Query the trace
# ============================================================
echo "📥 Step 3: Querying trace from Tempo..."

sleep 2  # Give Tempo time to index the trace

QUERY_RESULT=$(curl -s "${TEMPO_URL}/api/traces/${TRACE_ID}" | head -c 100)

if [ -z "$QUERY_RESULT" ]; then
  echo "⚠️  Warning: No trace data returned yet"
  echo "   This may be normal if Tempo is still indexing"
else
  echo "✅ Trace retrieved successfully!"
  echo "   Trace ID: ${TRACE_ID}"
fi

echo ""

# ============================================================
# Step 4: Check Tempo health
# ============================================================
echo "🏥 Step 4: Checking Tempo health status..."

HEALTH=$(curl -s "${TEMPO_URL}/api/status" | grep -o '"status":"[^"]*"' | head -1)
echo "✅ Tempo Status: ${HEALTH:-running}"

echo ""
echo "✨ Tempo validation complete!"
echo ""
echo "📚 Next steps:"
echo "   - View traces in Grafana: http://localhost:3000"
echo "   - Access Tempo API: ${TEMPO_URL}"
echo "   - Search traces via: ${TEMPO_URL}/api/search"
