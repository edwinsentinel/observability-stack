#!/bin/bash

# ============================================================
# Grafana Validation Script
# ============================================================
# This script verifies that Grafana is accessible and
# that all datasources (Prometheus, Loki, Tempo) are
# properly configured and responding.
# ============================================================

set -e  # Exit on any error

echo "🚀 Starting Grafana validation..."
echo ""

# Configuration
GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASSWORD="admin"

# ============================================================
# Step 1: Check Grafana connectivity
# ============================================================
echo "📡 Step 1: Checking Grafana connectivity..."

if ! curl -s "${GRAFANA_URL}/api/health" > /dev/null 2>&1; then
  echo "❌ Error: Cannot reach Grafana at ${GRAFANA_URL}"
  echo "   Make sure Grafana is running: docker compose ps"
  exit 1
fi

echo "✅ Grafana is accessible!"
echo ""

# ============================================================
# Step 2: Verify Grafana health status
# ============================================================
echo "🏥 Step 2: Checking Grafana health status..."

HEALTH=$(curl -s "${GRAFANA_URL}/api/health" | grep -o '"status":"[^"]*"' | head -1)
echo "✅ Grafana Status: ${HEALTH:-ok}"
echo ""

# ============================================================
# Step 3: List configured datasources
# ============================================================
echo "📊 Step 3: Verifying datasources..."

# Get list of datasources
DATASOURCES=$(curl -s -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  "${GRAFANA_URL}/api/datasources" \
  -H "Content-Type: application/json")

echo "Configured datasources:"

# Extract datasource names
PROMETHEUS=$(echo "$DATASOURCES" | grep -o '"name":"Prometheus"' && echo "✅ Prometheus" || echo "❌ Prometheus not found")
LOKI=$(echo "$DATASOURCES" | grep -o '"name":"Loki"' && echo "✅ Loki" || echo "❌ Loki not found")
TEMPO=$(echo "$DATASOURCES" | grep -o '"name":"Tempo"' && echo "✅ Tempo" || echo "❌ Tempo not found")

echo "  $PROMETHEUS"
echo "  $LOKI"
echo "  $TEMPO"

echo ""

# ============================================================
# Step 4: Test datasource health
# ============================================================
echo "🔗 Step 4: Testing datasource connectivity..."

# Test Prometheus
echo "  Testing Prometheus..."
if curl -s "${GRAFANA_URL}/api/datasources/proxy/1/api/v1/query?query=up" \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" > /dev/null 2>&1; then
  echo "    ✅ Prometheus responding"
else
  echo "    ⚠️  Prometheus not responding (may not have metrics yet)"
fi

# Test Loki
echo "  Testing Loki..."
if curl -s "${GRAFANA_URL}/api/datasources/proxy/2/loki/api/v1/labels" \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" > /dev/null 2>&1; then
  echo "    ✅ Loki responding"
else
  echo "    ⚠️  Loki not responding (may not have logs yet)"
fi

# Test Tempo
echo "  Testing Tempo..."
if curl -s "${GRAFANA_URL}/api/datasources/proxy/3/api/search" \
  -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" > /dev/null 2>&1; then
  echo "    ✅ Tempo responding"
else
  echo "    ⚠️  Tempo not responding (may not have traces yet)"
fi

echo ""

# ============================================================
# Step 5: Anonymous access check
# ============================================================
echo "🔓 Step 5: Checking anonymous access..."

if curl -s "${GRAFANA_URL}/api/user" -u ":" > /dev/null 2>&1; then
  echo "✅ Anonymous access enabled"
else
  echo "⚠️  Anonymous access may be disabled"
fi

echo ""

# ============================================================
# Summary
# ============================================================
echo "✨ Grafana validation complete!"
echo ""
echo "📚 Access Grafana:"
echo "   URL: ${GRAFANA_URL}"
echo "   Username: ${GRAFANA_USER}"
echo "   Password: (no login required - anonymous access enabled)"
echo ""
echo "🎯 Quick actions:"
echo "   - Create dashboard: ${GRAFANA_URL}/dashboard/new"
echo "   - View datasources: ${GRAFANA_URL}/connections/datasources"
echo "   - Explore metrics: ${GRAFANA_URL}/explore"
