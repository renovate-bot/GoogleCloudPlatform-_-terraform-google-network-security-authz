/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * ...
 */

variable "project_id" {
  type        = string
  description = "The ID of the project in which the resource belongs."
}

variable "location" {
  type        = string
  description = "The GCP region to deploy the resources."
}

variable "extensions_config" {
  description = "A map of unique Authz Extensions, indexed by their name."
  type = map(object({
    backend_service       = string
    authority             = optional(string)
    load_balancing_scheme = optional(string)
    description           = optional(string, "Managed by ADC")
    timeout               = optional(string, "0.1s")
    fail_open             = optional(bool, false)
    forward_headers       = optional(list(string), [])
    wire_format           = optional(string, "EXT_PROC_GRPC")
    metadata              = optional(map(string), {})
    model_armor_templates = optional(list(string), [])
    labels                = optional(map(string), {})
  }))
}

variable "policies_config" {
  description = "A map of Authz Policies with structured HTTP rules, indexed by name."
  type = map(object({
    action                = string
    load_balancing_scheme = string
    target_resources      = optional(list(string), [])
    description           = optional(string, "Managed by ADC")
    extension_names       = optional(list(string), [])
    iap_enabled           = optional(bool, false)
    policy_profile        = optional(string, "REQUEST_AUTHZ")
    labels                = optional(map(string), {})
    http_rules = optional(list(object({
      when = optional(string)
      from = optional(object({
        sources = optional(object({
          ip_blocks = optional(list(string), [])
          principals = optional(list(object({
            selector    = optional(string, "CLIENT_CERT_URI_SAN")
            exact       = optional(string)
            prefix      = optional(string)
            suffix      = optional(string)
            contains    = optional(string)
            ignore_case = optional(bool, false)
          })), [])
          resources = optional(list(object({
            tag_value_id_set = optional(list(string))
            iam_service_account = optional(object({
              exact       = optional(string)
              prefix      = optional(string)
              suffix      = optional(string)
              contains    = optional(string)
              ignore_case = optional(bool, false)
            }))
          })), [])
        }))
        not_sources = optional(object({
          ip_blocks = optional(list(string), [])
          principals = optional(list(object({
            selector    = optional(string, "CLIENT_CERT_URI_SAN")
            exact       = optional(string)
            ignore_case = optional(bool, false)
          })), [])
          resources = optional(list(object({
            tag_value_id_set = optional(list(string))
            iam_service_account = optional(object({
              exact       = optional(string)
              prefix      = optional(string)
              suffix      = optional(string)
              contains    = optional(string)
              ignore_case = optional(bool, false)
            }))
          })), [])
        }))
      }))
      to = optional(object({
        operations = optional(object({
          methods = optional(list(string), [])
          paths = optional(list(object({
            exact       = optional(string)
            prefix      = optional(string)
            suffix      = optional(string)
            contains    = optional(string)
            ignore_case = optional(bool, false)
          })), [])
          hosts = optional(list(object({
            exact       = optional(string)
            prefix      = optional(string)
            suffix      = optional(string)
            contains    = optional(string)
            ignore_case = optional(bool, false)
          })), [])
          headers = optional(list(object({
            name        = string
            exact       = optional(string)
            prefix      = optional(string)
            suffix      = optional(string)
            contains    = optional(string)
            ignore_case = optional(bool, false)
          })), [])
          mcp = optional(object({
            base_protocol_methods_option = optional(string)
            methods = list(object({
              name   = string
              params = optional(string)
            }))
          }))
        }))
        not_operations = optional(object({
          methods = optional(list(string), [])
          paths = optional(list(object({
            exact       = optional(string)
            prefix      = optional(string)
            suffix      = optional(string)
            contains    = optional(string)
            ignore_case = optional(bool, false)
          })), [])
          hosts = optional(list(object({
            exact = string
          })), [])
        }))
      }))
    })), [])
  }))
}

variable "authz_policy_map_json" {
  type        = string
  description = "Json encoded map of authz policy name to authz policy object."
  default     = ""
}

variable "authz_extension_map_json" {
  type        = string
  description = "Json encoded map of authz extension name to authz extension object."
  default     = ""
}
