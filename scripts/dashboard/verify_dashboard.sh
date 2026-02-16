#!/bin/bash

echo "========================================"
echo "Dashboard Verification - Day 18"
echo "Date: $(date)"
echo "========================================"
echo

# Test 1: List all dashboards
echo "Test 1: Listing all dashboards..."
aws --endpoint-url=http://localhost:4566 cloudwatch list-dashboards
echo

# Test 2: Get operations dashboard
echo "Test 2: Getting operations dashboard details..."
aws --endpoint-url=http://localhost:4566 cloudwatch get-dashboard \
  --dashboard-name operations-dashboard \
  --query 'DashboardBody' \
  --output text > /tmp/dashboard_body.json

echo "Dashboard retrieved successfully"
echo

# Test 3: Count widgets
echo "Test 3: Analyzing dashboard structure..."
WIDGET_COUNT=$(cat /tmp/dashboard_body.json | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data['widgets']))")
echo "Total widgets: $WIDGET_COUNT"
echo

# Test 4: List widget types
echo "Test 4: Widget breakdown..."
cat /tmp/dashboard_body.json | python3 << 'PYTHON'
import sys
import json

data = json.loads(sys.stdin.read())
widgets = data['widgets']

# Count widget types
metric_widgets = sum(1 for w in widgets if w.get('type') == 'metric')
alarm_widgets = sum(1 for w in widgets if w.get('type') == 'alarm')
log_widgets = sum(1 for w in widgets if w.get('type') == 'log')

print(f"Metric widgets: {metric_widgets}")
print(f"Alarm widgets: {alarm_widgets}")
print(f"Log widgets: {log_widgets}")
print()

# List all widget titles
print("Widget titles:")
for i, widget in enumerate(widgets, 1):
    title = widget.get('properties', {}).get('title', 'Untitled')
    widget_type = widget.get('type', 'unknown')
    print(f"  {i}. {title} ({widget_type})")
PYTHON

# Cleanup
rm -f /tmp/dashboard_body.json

echo
echo "========================================"
echo "Dashboard verification complete"
echo "========================================"
