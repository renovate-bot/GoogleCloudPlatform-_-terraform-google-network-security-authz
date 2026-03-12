/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * ...
 */

output "id" {
  description = "The fully qualified identifier of the AuthzExtension resource."
  value       = google_network_services_authz_extension.this.id
}

output "name" {
  description = "The name of the created AuthzExtension resource."
  value       = google_network_services_authz_extension.this.name
}

output "create_time" {
  description = "The timestamp when the resource was created."
  value       = google_network_services_authz_extension.this.create_time
}

output "update_time" {
  description = "The timestamp when the resource was last updated."
  value       = google_network_services_authz_extension.this.update_time
}

output "effective_labels" {
  description = "All labels present on the resource in GCP, including those from Terraform and other sources."
  value       = google_network_services_authz_extension.this.effective_labels
}

output "terraform_labels" {
  description = "The combination of labels configured directly on the resource and default provider labels."
  value       = google_network_services_authz_extension.this.terraform_labels
}
