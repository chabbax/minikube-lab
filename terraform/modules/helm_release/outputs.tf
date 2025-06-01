output "release_name" {
  description = "The name of the Helm release that was installed or upgraded."
  value       = helm_release.this.name
}

output "status" {
  description = "The status of the Helm release (\"deployed\", \"failed\", etc.)."
  value       = helm_release.this.status
}

output "namespace" {
  description = "The namespace in which the release was deployed."
  value       = helm_release.this.namespace
}

output "revision" {
  description = "The revision of the installed release."
  value       = helm_release.this.revision
}
