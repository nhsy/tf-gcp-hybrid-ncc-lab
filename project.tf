resource "google_compute_project_metadata" "oslogin" {
  metadata = {
    enable-oslogin = "TRUE"
  }
}