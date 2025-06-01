#!/bin/bash
set -e

# Usage: ./taint_node.sh <node_name> <key> <value> <effect>
NODE="$1"
KEY="$2"
VALUE="$3"
EFFECT="$4"

echo "Applying taint: $KEY=$VALUE:$EFFECT to node $NODE"

if ! kubectl get node "$NODE" -o json | jq -e \
  ".spec.taints[]? | select(.key == \"$KEY\" and .value == \"$VALUE\" and .effect == \"$EFFECT\")" > /dev/null; then
  kubectl taint nodes "$NODE" "$KEY=$VALUE:$EFFECT" --overwrite
else
  echo "Taint already exists on $NODE"
fi
