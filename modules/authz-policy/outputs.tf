/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "create_time" {
  description = "The timestamp when the authz policy was created."
  value       = google_network_security_authz_policy.authz_policy.create_time
}

output "id" {
  description = "The canonical ID of the authz policy."
  value       = google_network_security_authz_policy.authz_policy.id
}

output "name" {
  description = "The name of the authz policy."
  value       = google_network_security_authz_policy.authz_policy.name
}

output "update_time" {
  description = "The timestamp when the authz policy was last updated."
  value       = google_network_security_authz_policy.authz_policy.update_time
}

output "effective_labels" {
  description = "All labels present on the resource in GCP."
  value       = google_network_security_authz_policy.authz_policy.effective_labels
}

output "terraform_labels" {
  description = "The combination of labels configured directly and default provider labels."
  value       = google_network_security_authz_policy.authz_policy.terraform_labels
}
