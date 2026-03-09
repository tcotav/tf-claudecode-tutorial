terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Remote state backend (recommended for team use)
  # Uncomment and configure once you have a GCS bucket for state storage.
  # See: https://developer.hashicorp.com/terraform/language/backend/gcs
  #
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state"
  # }
}

provider "google" {
  project = local.project_id
  region  = local.region
}
