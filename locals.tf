# Tutorial configuration values
#
# For this tutorial, values are defined here as locals so everything is visible
# in one place without needing to manage a separate tfvars file.
#
# In production, you would:
#   1. Move sensitive values (project_id, etc.) to terraform.tfvars or environment variables
#   2. Use a remote state backend (GCS bucket) so your team shares the same state file
#      See the commented-out backend block in providers.tf for an example.
#
locals {
  project_id   = "your-gcp-project-id" # Replace with your GCP project ID
  region       = "us-central1"
  service_name = "my-app"
  image        = "us-docker.pkg.dev/cloudrun/container/hello"
}
