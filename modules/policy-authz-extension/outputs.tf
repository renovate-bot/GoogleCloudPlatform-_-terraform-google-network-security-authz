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
  description = "Maps each policy name to its assigned extension IDs (if CUSTOM action)."
  value = {
    for k, v in local.final_policies_config : k => try(v.extension_names, []) 
    if try(v.action, "") == "CUSTOM" && ! try(v.iap_enabled, false)
  }
}
