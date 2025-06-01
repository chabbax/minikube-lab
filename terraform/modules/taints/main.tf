/*
  @params var.taints  - List of taint objects. Each contains:
                        node_name (string) : the target node’s name
                        key       (string) : taint key
                        value     (string) : taint value
                        effect    (string) : taint effect (NoSchedule, PreferNoSchedule, NoExecute)

  @note: Iterates over each taint, using a unique key per entry in the format “<node_name>-<key>-<value>-<effect>”.
  @note: The `triggers = { always_run = timestamp() }` ensures the provisioner re-runs on every apply.
  @note: Uses an external shell script (`resources/taint_node.sh`) to apply taints idempotently.
*/
resource "null_resource" "taint_nodes" {
  for_each = {
    for t in var.taints : "${t.node_name}-${t.key}-${t.value}-${t.effect}" => t
  }

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "${path.module}/resources/taint_node.sh \"${each.value.node_name}\" \"${each.value.key}\" \"${each.value.value}\" \"${each.value.effect}\""
    interpreter = ["/bin/bash", "-c"]
  }
}
