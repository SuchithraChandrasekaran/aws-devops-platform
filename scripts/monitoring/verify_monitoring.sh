#!/bin/bash

echo "========================================"
echo "Monitoring Stack Verification - Day 19"
echo "Date: $(date)"
echo "========================================"
echo

# Test 1: Check Prometheus
echo "Test 1: Checking Prometheus..."
if curl -sf http://localhost:9090/-/healthy > /dev/null; then
    echo "✓ Prometheus is healthy"
    
    # Get Prometheus targets
    TARGETS=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    active = data['data']['activeTargets']
    print(f'Active targets: {len(active)}')
    for target in active:
        health = target['health']
        job = target['labels']['job']
        state = '✓' if health == 'up' else '✗'
        print(f'  {state} {job}: {health}')
except:
    print('  Could not parse targets')
" 2>/dev/null)
    echo "$TARGETS"
else
    echo "✗ Prometheus is not accessible"
fi
echo

# Test 2: Check Grafana
echo "Test 2: Checking Grafana..."
if curl -sf http://localhost:3000/api/health > /dev/null; then
    echo "✓ Grafana is healthy"
    echo "  URL: http://localhost:3000"
    echo "  Username: admin"
    echo "  Password: admin"
else
    echo "✗ Grafana is not accessible"
fi
echo

# Test 3: Check Node Exporter
echo "Test 3: Checking Node Exporter..."
if curl -sf http://localhost:9100/metrics > /dev/null; then
    METRIC_COUNT=$(curl -s http://localhost:9100/metrics 2>/dev/null | grep -c "^node_" || echo "0")
    echo "✓ Node Exporter is running"
    echo "  Metrics available: ~$METRIC_COUNT node_* metrics"
else
    echo "✗ Node Exporter is not accessible"
fi
echo

# Test 4: Check App Exporter
echo "Test 4: Checking App Exporter..."
if curl -sf http://localhost:8000/metrics > /dev/null; then
    METRIC_COUNT=$(curl -s http://localhost:8000/metrics 2>/dev/null | grep -c "^myapp_" || echo "0")
    echo "✓ App Exporter is running"
    echo "  Metrics available: $METRIC_COUNT myapp_* metrics"
else
    echo "✗ App Exporter is not accessible"
fi
echo

# Test 5: Query Prometheus
echo "Test 5: Querying Prometheus metrics..."
QUERY_RESULT=$(curl -s "http://localhost:9090/api/v1/query?query=up" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data['status'] == 'success':
        results = data['data']['result']
        print(f'Query successful: {len(results)} results')
        for r in results[:3]:
            job = r['metric'].get('job', 'unknown')
            value = r['value'][1]
            print(f'  {job}: {value}')
    else:
        print('Query failed')
except:
    print('Error parsing response')
" 2>/dev/null)
echo "$QUERY_RESULT"
echo

echo "========================================"
echo "Monitoring stack verification complete"
echo "========================================"
echo
echo "Access URLs:"
echo "  Prometheus: http://localhost:9090"
echo "  Grafana:    http://localhost:3000 (admin/admin)"
echo "  Node Exp:   http://localhost:9100/metrics"
echo "  App Exp:    http://localhost:8000/metrics"
