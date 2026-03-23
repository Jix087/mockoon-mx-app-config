#!/usr/bin/env bash
# ============================================================
# Deploy Mendix Mock APIs to Kubernetes
# ============================================================
# Usage:
#   ./k8s/apply.sh [namespace]    default namespace: mockoon
#
# Prerequisites:
#   - JSON files already on the node at /opt/mockoon-data/
#     (run ./k8s/upload.sh first if needed)
#   - kubectl configured for the target cluster
# ============================================================

set -euo pipefail

NAMESPACE="${1:-mockoon}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Applying manifests to namespace: $NAMESPACE"
kubectl apply -f "$SCRIPT_DIR/mockoon.yaml"

echo ""
echo "Waiting for data-loader Job to complete..."
kubectl wait \
  --for=condition=complete \
  job/mockoon-data-loader \
  -n "$NAMESPACE" \
  --timeout=60s

echo ""
echo "Waiting for Deployments to become ready..."
for dep in mendix-deploy-api mendix-build-api mendix-repository-api; do
  kubectl rollout status deployment/"$dep" -n "$NAMESPACE" --timeout=90s
done

echo ""
echo "All services ready. Pods:"
kubectl get pods -n "$NAMESPACE" -l app=mendix-mock
