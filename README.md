# Google Cloud Network Security Authorization Modules

This repository provides a consolidated suite of Terraform modules for deploying and managing **Network Security Authorization Policies and Extensions** on Google Cloud. 

These modules act as a unified API for enforcing access control across the 1N networking stack, encompassing Application Load Balancers (L7 XLB/ILB) and Agent Gateways. By facilitating Service Extension callouts, these modules enable the delegation of authorization decisions to custom engines for complex logic—such as AI guardrails via Model Armor—which standard RBAC cannot express.

## Modules Included

This repository contains three standalone components designed for Application Design Center (ADC) integration:

* **[Integrated Authz](./modules/integrated-authz/)**: A unified module that provisions both Authorization Extensions and Policies, handling the complex many-to-many relationships and deduplicated extension creation required for Agent Cloud integrations.
* **[Authorization Policy](./modules/authz-policy/)**: A standalone module for provisioning a `google_network_security_authz_policy` resource, supporting fine-grained access control via Model Context Protocol (MCP) attributes.
* **[Authorization Extension](./modules/authz-extension/)**: A standalone module for provisioning a `google_network_services_authz_extension` resource, used to configure how traffic is authorized before it reaches a backend service.

## Usage

You can use the **Integrated Authz** module to provision a cohesive authorization layer:

```hcl
module "integrated_authz" {
  source     = "github.com/your-org/your-repo//modules/integrated-authz"
  project_id = "your-gcp-project-id"
  location   = "us-central1"

  extensions_config = {
    "my-authz-extension" = {
      authority             = "authz-ext.example.com"
      backend_service       = "projects/your-gcp-project-id/global/backendServices/my-ext-authz-backend"
      load_balancing_scheme = "INTERNAL_MANAGED"
      timeout               = "10s"
      fail_open             = false
    }
  }

  policies_config = {
    "my-authz-policy" = {
      action                = "CUSTOM"
      load_balancing_scheme = "INTERNAL_MANAGED"
      target_resources      = ["projects/your-gcp-project-id/locations/us-central1/targetHttpProxies/my-proxy"]
      extension_names       = ["my-authz-extension"]
    }
  }
}
