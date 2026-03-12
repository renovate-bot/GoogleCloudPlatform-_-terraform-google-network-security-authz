### Policy Module: `modules/authz-policy/README.md`
Adapted directly from the original `terraform-google-security-auth-policy` repository ([<img src="https://moma.corp.google.com/images/navstar.png" width=15 style="vertical-align:middle;"> source](https://github.com/Daisyprakash/terraform-google-security-auth-policy/blob/main/README.md?content_ref=this+module+creates+a+google_network_services_authz_extension+resource+which+allows+for+flexible+authorization+policies+in+a+service+mesh+by+integrating+with+an+external+grpc+authorizer)).

```markdown
# Google Cloud Network Security AuthzPolicy

This module creates a `google_network_security_authz_policy` resource, which defines rules for determining whether incoming requests are allowed or denied. It can enforce access control locally or delegate decisions to an external extension via a `CUSTOM` provider.

## Usage

Here is a basic example of how to use this module:

```hcl
module "authz_policy" {
  source     = "../../modules/authz-policy"
  project_id = "your-gcp-project-id"
  name       = "my-custom-authz-policy"
  location   = "global"
  action     = "ALLOW"
  
  target = {
    load_balancing_scheme = "INTERNAL_MANAGED"
    resources             = ["projects/your-gcp-project-id/locations/global/targetHttpProxies/my-proxy"]
  }

  labels = {
    env = "production"
  }
}
