output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.app.uri
}

output "service_account_email" {
  description = "Email of the service account the Cloud Run service runs as"
  value       = google_service_account.app.email
}
