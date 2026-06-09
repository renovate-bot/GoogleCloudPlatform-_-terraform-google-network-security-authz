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

/**
 * Unit Kind 3: Authz Policies and Extensions
 * This module provisions the security layer for the Agent Gateway.
 * It ensures many-to-many relationships and deduplicated extension creation.
 */


locals {
  authz_policy_map_json       = var.authz_policy_map_json == "" || var.authz_policy_map_json == null ? {} : jsondecode(var.authz_policy_map_json)
  local_authz_policy_map_json = { for k, v in local.authz_policy_map_json : k => jsondecode(v) }

  final_policies_config = merge(var.policies_config, local.local_authz_policy_map_json)

  authz_extension_map_json       = var.authz_extension_map_json == "" || var.authz_extension_map_json == null ? {} : jsondecode(var.authz_extension_map_json)
  local_authz_extension_map_json = { for k, v in local.authz_extension_map_json : k => jsondecode(v) }

  final_extensions_config = merge(var.extensions_config, local.local_authz_extension_map_json)
}

resource "google_network_security_authz_policy" "policy" {
  for_each = local.final_policies_config
  provider = google-beta

  project  = local.resolved_project_identifier
  location = var.location
  name     = each.key

  action         = each.value.action
  policy_profile = try(each.value.policy_profile, "REQUEST_AUTHZ")
  description    = try(each.value.description, "Managed by ADC")
  labels         = try(each.value.labels, {})

  target {
    load_balancing_scheme = try(each.value.load_balancing_scheme, "INTERNAL_MANAGED")
    resources             = try(each.value.target.resources, each.value.target_resources, [])
  }

  # Logic for Custom Provider (IAP or Extensions)
  dynamic "custom_provider" {
    # Create block if action is CUSTOM or if sub-fields exist in legacy payload
    for_each = (each.value.action == "CUSTOM" || try(each.value.iap_enabled, false) || length(try(each.value.extension_names, [])) > 0) ? [1] : []
    content {
      dynamic "cloud_iap" {
        for_each = try(each.value.iap_enabled, false) ? [1] : []
        content {
          enabled = true
        }
      }

      dynamic "authz_extension" {
        for_each = (!try(each.value.iap_enabled, false) && length(try(each.value.extension_names, [])) > 0) ? [1] : []
        content {
          resources = [
            for name in each.value.extension_names : 
            try(google_network_services_authz_extension.extension[name].id, name)
          ]
        }
      }
    }
  }

  # Map full nested HTTP Rules
  dynamic "http_rules" {
    for_each = try(each.value.http_rules, [])
    content {
      when = try(http_rules.value.when, null)

      dynamic "from" {
        for_each = try(http_rules.value.from, null) != null ? [http_rules.value.from] : []
        content {
          dynamic "sources" {
            for_each = try(from.value.sources, null) != null ? [from.value.sources] : []
            content {
              dynamic "principals" {
                for_each = try(sources.value.principals, [])
                content {
                  principal_selector = try(principals.value.selector, "CLIENT_CERT_URI_SAN")
                  principal {
                    exact       = try(principals.value.exact, null)
                    prefix      = try(principals.value.prefix, null)
                    suffix      = try(principals.value.suffix, null)
                    contains    = try(principals.value.contains, null)
                    ignore_case = try(principals.value.ignore_case, false)
                  }
                }
              }
              dynamic "ip_blocks" {
                for_each = try(sources.value.ip_blocks, [])
                content {
                  prefix = split("/", ip_blocks.value)[0]
                  length = tonumber(split("/", ip_blocks.value)[1])
                }
              }
              dynamic "resources" {
                for_each = try(sources.value.resources, [])
                content {
                  dynamic "tag_value_id_set" {
                    for_each = try(resources.value.tag_value_id_set, null) != null ? [resources.value.tag_value_id_set] : []
                    content {
                      ids = tag_value_id_set.value
                    }
                  }
                  dynamic "iam_service_account" {
                    for_each = try(resources.value.iam_service_account, null) != null ? [resources.value.iam_service_account] : []
                    content {
                      exact       = try(iam_service_account.value.exact, null)
                      prefix      = try(iam_service_account.value.prefix, null)
                      suffix      = try(iam_service_account.value.suffix, null)
                      contains    = try(iam_service_account.value.contains, null)
                      ignore_case = try(iam_service_account.value.ignore_case, false)
                    }
                  }
                }
              }
            }
          }

          dynamic "not_sources" {
            for_each = try(from.value.not_sources, null) != null ? [from.value.not_sources] : []
            content {
              dynamic "principals" {
                for_each = try(not_sources.value.principals, [])
                content {
                  principal_selector = try(principals.value.selector, "CLIENT_CERT_URI_SAN")
                  principal {
                    exact       = try(principals.value.exact, null)
                    ignore_case = try(principals.value.ignore_case, false)
                  }
                }
              }
              dynamic "ip_blocks" {
                for_each = try(not_sources.value.ip_blocks, [])
                content {
                  prefix = split("/", ip_blocks.value)[0]
                  length = tonumber(split("/", ip_blocks.value)[1])
                }
              }
              dynamic "resources" {
                for_each = try(not_sources.value.resources, [])
                content {
                  dynamic "tag_value_id_set" {
                    for_each = try(resources.value.tag_value_id_set, null) != null ? [resources.value.tag_value_id_set] : []
                    content {
                      ids = tag_value_id_set.value
                    }
                  }
                  dynamic "iam_service_account" {
                    for_each = try(resources.value.iam_service_account, null) != null ? [resources.value.iam_service_account] : []
                    content {
                      exact       = try(iam_service_account.value.exact, null)
                      prefix      = try(iam_service_account.value.prefix, null)
                      suffix      = try(iam_service_account.value.suffix, null)
                      contains    = try(iam_service_account.value.contains, null)
                      ignore_case = try(iam_service_account.value.ignore_case, false)
                    }
                  }
                }
              }
            }
          }
        }
      }

      dynamic "to" {
        for_each = try(http_rules.value.to, null) != null ? [http_rules.value.to] : []
        content {
          dynamic "operations" {
            for_each = try(to.value.operations, null) != null ? [to.value.operations] : []
            content {
              methods = try(operations.value.methods, [])

              dynamic "paths" {
                for_each = try(operations.value.paths, [])
                content {
                  exact       = try(paths.value.exact, null)
                  prefix      = try(paths.value.prefix, null)
                  suffix      = try(paths.value.suffix, null)
                  contains    = try(paths.value.contains, null)
                  ignore_case = try(paths.value.ignore_case, false)
                }
              }

              dynamic "hosts" {
                for_each = try(operations.value.hosts, [])
                content {
                  exact       = try(hosts.value.exact, null)
                  prefix      = try(hosts.value.prefix, null)
                  suffix      = try(hosts.value.suffix, null)
                  contains    = try(hosts.value.contains, null)
                  ignore_case = try(hosts.value.ignore_case, false)
                }
              }

              dynamic "mcp" {
                # Safeguard for the new MCP block type
                for_each = try(operations.value.mcp, null) != null ? [operations.value.mcp] : []
                content {
                  base_protocol_methods_option = try(mcp.value.base_protocol_methods_option, null)
                  dynamic "methods" {
                    for_each = try(mcp.value.methods, [])
                    content {
                      name = methods.value.name
                      dynamic "params" {
                        for_each = try(methods.value.params, null) != null ? [methods.value.params] : []
                        content {
                          exact = params.value
                        }
                      }
                    }
                  }
                }
              }

              dynamic "header_set" {
                for_each = length(try(operations.value.headers, [])) > 0 ? [1] : []
                content {
                  dynamic "headers" {
                    for_each = operations.value.headers
                    content {
                      name = headers.value.name
                      dynamic "value" {
                        for_each = [1]
                        content {
                          exact       = try(headers.value.exact, null)
                          prefix      = try(headers.value.prefix, null)
                          suffix      = try(headers.value.suffix, null)
                          contains    = try(headers.value.contains, null)
                          ignore_case = try(headers.value.ignore_case, false)
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          dynamic "not_operations" {
            for_each = try(to.value.not_operations, null) != null ? [to.value.not_operations] : []
            content {
              methods = try(not_operations.value.methods, [])
              dynamic "paths" {
                for_each = try(not_operations.value.paths, [])
                content {
                  exact       = try(paths.value.exact, null)
                  prefix      = try(paths.value.prefix, null)
                  suffix      = try(paths.value.suffix, null)
                  contains    = try(paths.value.contains, null)
                  ignore_case = try(paths.value.ignore_case, false)
                }
              }
              dynamic "hosts" {
                for_each = try(not_operations.value.hosts, [])
                content {
                  exact       = try(hosts.value.exact, null)
                  prefix      = try(hosts.value.prefix, null)
                  suffix      = try(hosts.value.suffix, null)
                  contains    = try(hosts.value.contains, null)
                  ignore_case = try(hosts.value.ignore_case, false)
                }
              }

              dynamic "header_set" {
                for_each = length(try(not_operations.value.headers, [])) > 0 ? [1] : []
                content {
                  dynamic "headers" {
                    for_each = not_operations.value.headers
                    content {
                      name = headers.value.name
                      dynamic "value" {
                        for_each = [1]
                        content {
                          exact       = try(headers.value.exact, null)
                          prefix      = try(headers.value.prefix, null)
                          suffix      = try(headers.value.suffix, null)
                          contains    = try(headers.value.contains, null)
                          ignore_case = try(headers.value.ignore_case, false)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}