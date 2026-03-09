# Service account the Cloud Run service runs as
resource "google_service_account" "app" {
  account_id   = "${local.service_name}-sa"
  display_name = "${local.service_name} service account"
}

# Cloud Run service
resource "google_cloud_run_v2_service" "app" {
  name     = local.service_name
  location = local.region

  template {
    service_account = google_service_account.app.email

    containers {
      image = local.image
    }
  }
}

# Allow unauthenticated (public) access to the service
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.app.name
  location = google_cloud_run_v2_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
