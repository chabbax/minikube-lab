output "namespace_names" {
  description = "List of namespace names created"
  value       = [for ns in kubernetes_namespace.this : ns.metadata[0].name]
}
