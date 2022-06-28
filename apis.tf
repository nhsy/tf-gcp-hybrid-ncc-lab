resource "google_project_service" "apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "networkconnectivity.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "time_sleep" "api_delay" {
  create_duration = "30s"
  depends_on      = [google_project_service.apis]
}