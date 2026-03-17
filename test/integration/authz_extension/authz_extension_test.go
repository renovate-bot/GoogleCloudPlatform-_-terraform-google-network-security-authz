package authz_extension

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestAuthzExtension(t *testing.T) {
	// Initializes the test using the 'examples/authz_extension' directory
	bpt := tft.NewTFBlueprintTest(t)

	bpt.DefineVerify(func(assert *assert.Assertions) {
		// Verify no drift happens after terraform apply.
		// This proves that Terraform successfully created the resource and the state is stable.
		bpt.DefaultVerify(assert)

		// Get outputs from the Terraform example to ensure they are populated correctly
		projectID := bpt.GetStringOutput("project_id")
		assert.NotEmpty(projectID, "project_id output should not be empty")

		// Skipping the gcloud command since the CLI doesn't fully support authz-extensions yet.
	})

	bpt.Test()
}
