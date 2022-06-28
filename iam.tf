# Least privilege service account for GCE VMs
resource "google_service_account" "appliance_compute" {
  account_id  = "sa-appliance-compute"
  description = "GCE Appliance SA"

  depends_on = [google_project_service.apis]
}

resource "google_project_iam_member" "appliance_compute" {
  for_each = toset([
    "roles/monitoring.viewer",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/stackdriver.resourceMetadata.writer",
  ])
  member  = "serviceAccount:${google_service_account.appliance_compute.email}"
  project = var.project_id
  role    = each.value
}

resource "google_service_account" "compute" {
  account_id  = "sa-compute"
  description = "GCE VM SA"

  depends_on = [google_project_service.apis]
}

resource "google_project_iam_member" "compute" {
  for_each = toset([
    "roles/monitoring.viewer",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/stackdriver.resourceMetadata.writer",
  ])
  member  = "serviceAccount:${google_service_account.compute.email}"
  project = var.project_id
  role    = each.value
}
