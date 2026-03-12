### Integrated Module: `modules/integrated-authz/README.md`
Adapted from the original `terraform-google-policy-authz-extension` repository ([<img src="https://moma.corp.google.com/images/navstar.png" width=15 style="vertical-align:middle;"> source](https://github.com/vandnagarggoogle/terraform-google-policy-authz-extension/blob/main/README.md?content_ref=to+generated+module+detailed+this+module+was+generated+from+terraform+google+module+template)).

```markdown
# Google Cloud Integrated Authorization Policies and Extensions

This module creates both `google_network_security_authz_policy` and `google_network_services_authz_extension` resources in a coordinated manner. It handles many-to-many mappings and prevents duplication by allowing you to define maps of configurations for both extensions and policies.

## Usage

Basic usage of this module is as follows:

```hcl
module "policy_authz_extension" {
  source = "../../modules/integrated-authz"

  project_id = "your-gcp-project-id"
  location   = "us-central1"

  extensions_config = {
    "my-extension" = {
      authority             = "auth.example.com"
      backend_service       = "projects/your-gcp-project-id/global/backendServices/ext-svc"
      load_balancing_scheme = "INTERNAL_MANAGED"
    }
  }

  policies_config = {
    "my-policy" = {
      action                = "CUSTOM"
      load_balancing_scheme = "INTERNAL_MANAGED"
      target_resources      = ["projects/your-gcp-project-id/locations/us-central1/targetHttpProxies/proxy"]
      extension_names       = ["my-extension"]
    }
  }
}
