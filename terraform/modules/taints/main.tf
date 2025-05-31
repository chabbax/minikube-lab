resource "null_resource" "taint_nodes" {
  for_each = {
    for t in var.taints : "${t.node_name}-${t.key}-${t.value}-${t.effect}" => t
  }

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = <<EOT
      #!/bin/bash
      set -e

      NODE="${each.value.node_name}"
      KEY="${each.value.key}"
      VALUE="${each.value.value}"
      EFFECT="${each.value.effect}"

      echo "Applying taint: $KEY=$VALUE:$EFFECT to node $NODE"

      if ! kubectl get node "$NODE" -o json | jq -e \
        ".spec.taints[]? | select(.key == \\"$KEY\\" and .value == \\"$VALUE\\" and .effect == \\"$EFFECT\\")" > /dev/null; then
        kubectl taint nodes "$NODE" "$KEY=$VALUE:$EFFECT" --overwrite
      else
        echo "Taint already exists on $NODE"
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
