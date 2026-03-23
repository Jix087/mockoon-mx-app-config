#!/usr/bin/env bash
# ============================================================
# Upload Mockoon JSON files to cluster node(s)
# ============================================================
# Usage:
#   ./k8s/upload.sh <node-ssh-host> [namespace]
#
# This places the JSON files in /opt/mockoon-data on the node,
# which is the hostPath the data-loader Job reads from.
#
# Example:
#   ./k8s/upload.sh ubuntu@10.0.0.5
#   ./k8s/upload.sh ec2-user@my-node.example.com staging
# ============================================================

set -euo pipefail

NODE_HOST="${1:?Usage: $0 <node-ssh-host> [namespace]}"
NAMESPACE="${2:-mockoon}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Uploading JSON files to $NODE_HOST:/opt/mockoon-data ..."
ssh "$NODE_HOST" "mkdir -p /opt/mockoon-data"
scp \
  "$DATA_DIR/mendix-deploy-api.json" \
  "$DATA_DIR/mendix-build-api.json" \
  "$DATA_DIR/mendix-repository-api.json" \
  "$NODE_HOST:/opt/mockoon-data/"

echo "Files uploaded:"
ssh "$NODE_HOST" "ls -lh /opt/mockoon-data/"

echo ""
echo "Now apply the manifests:"
echo "  kubectl apply -f $SCRIPT_DIR/mockoon.yaml"
echo "  kubectl wait --for=condition=complete job/mockoon-data-loader -n $NAMESPACE --timeout=60s"
