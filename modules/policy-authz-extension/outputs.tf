/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * ...
 */

output "policy_ids" {
  description = "The fully qualified resource names designating the authorization policies provisioned by the module."
  value       = { for k, v in google_network_security_authz_policy.policy : k => v.id }
}

output "extension_ids" {
  description = "The fully qualified resource names designating the authorization extensions provisioned by the module."
  value       = { for k, v in google_network_services_authz_extension.extension : k => v.id }
}

output "policy_extension_map" {
  description = "A JSON string representing a mapping of each authorization policy name to a list of its designated authorization extension resource identifiers."
  value = jsonencode({
    for k, v in var.policies_config : k => [
      for name in try(v.extension_names, []) : google_network_services_authz_extension.extension[name].id
    ]
  })
}

