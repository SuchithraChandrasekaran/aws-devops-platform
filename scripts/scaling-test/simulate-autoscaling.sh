#!/bin/bash
METRIC_FILE="/tmp/fake-cpu-metric.txt"
SCALE_OUT_THRESHOLD=70
SCALE_IN_THRESHOLD=30
MAX_REPLICAS=5
MIN_REPLICAS=1
CURRENT_REPLICAS=1
CYCLES=6

echo "========================================"
echo "Auto-scaling Simulation Started"
echo "Scale-out threshold : CPU > ${SCALE_OUT_THRESHOLD}%"
echo "Scale-in  threshold : CPU < ${SCALE_IN_THRESHOLD}%"
echo "========================================"

get_cpu_metric() {
  if [ -f "$METRIC_FILE" ]; then cat "$METRIC_FILE"
  else echo $((RANDOM % 100)); fi
}

for cycle in $(seq 1 $CYCLES); do
  CPU=$(get_cpu_metric)
  echo "[Cycle ${cycle}/${CYCLES}] CPU: ${CPU}% | Replicas: ${CURRENT_REPLICAS}"

  if [ "$CPU" -gt "$SCALE_OUT_THRESHOLD" ] && [ "$CURRENT_REPLICAS" -lt "$MAX_REPLICAS" ]; then
    CURRENT_REPLICAS=$((CURRENT_REPLICAS + 1))
    echo "[SCALE-OUT] -> ${CURRENT_REPLICAS} replicas"
    cd ~/aws-devops-platform/applications/sample-app && docker compose up -d --scale app=$CURRENT_REPLICAS
  elif [ "$CPU" -lt "$SCALE_IN_THRESHOLD" ] && [ "$CURRENT_REPLICAS" -gt "$MIN_REPLICAS" ]; then
    CURRENT_REPLICAS=$((CURRENT_REPLICAS - 1))
    echo "[SCALE-IN] -> ${CURRENT_REPLICAS} replicas"
    cd ~/aws-devops-platform/applications/sample-app && docker compose up -d --scale app=$CURRENT_REPLICAS
  else
    echo "[STABLE] No action"
  fi
  sleep 2
done

echo "========================================"
echo "Simulation complete. Final replicas: ${CURRENT_REPLICAS}"
echo "========================================"
