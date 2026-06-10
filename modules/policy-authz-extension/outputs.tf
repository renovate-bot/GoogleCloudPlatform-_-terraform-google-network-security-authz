/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * ...
 */

output "extension_ids" {
  description = "Map of extension names to their unique resource IDs."
  value       = { for k, v in google_network_services_authz_extension.extension : k => v.id }
}

output "policy_ids" {
  description = "Map of policy names to their unique resource IDs."
  value       = { for k, v in google_network_security_authz_policy.policy : k => v.id }
}


output "policy_extension_map" {
  description = "Maps each policy name to its assigned extension IDs (if CUSTOM action)."
  value = {
    for k, v in local.final_policies_config : k => try(v.extension_names, [])
    if try(v.action, "") == "CUSTOM" && !try(v.iap_enabled, false)
  }
}
