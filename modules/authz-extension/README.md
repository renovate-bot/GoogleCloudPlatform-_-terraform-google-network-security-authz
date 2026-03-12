### Extension Module: `modules/authz-extension/README.md`
Adapted directly from the original `terraform-google-network-security-auth-extension` repository ([<img src="https://moma.corp.google.com/images/navstar.png" width=15 style="vertical-align:middle;"> source](https://github.com/Daisyprakash/terraform-google-network-security-auth-extension/blob/main/README.md?content_ref=here+is+a+basic+example+of+how+to+use+this+module+module+authz_extension+source+or+a+path+to+this+module)).

```markdown
# Google Cloud Network Services AuthzExtension

This module creates a `google_network_services_authz_extension` resource, which allows for flexible authorization policies in a service mesh or load balancer by integrating with an external gRPC authorizer. It is used to configure how traffic is authorized before it reaches a backend service.

## Usage

Here is a basic example of how to use this module:

```hcl
module "authz_extension" {
  source     = "../../modules/authz-extension"
  project_id = "your-gcp-project-id"
  name       = "my-custom-authz-extension"
  location   = "global"
  service    = "projects/your-gcp-project-id/global/backendServices/my-ext-authz-backend-service"
  authority  = "auth.example.com"
  timeout    = "5s"
  load_balancing_scheme = "INTERNAL_MANAGED"
  description = "Authorization extension for my service mesh."
  labels = {
    env = "production"
  }
}
