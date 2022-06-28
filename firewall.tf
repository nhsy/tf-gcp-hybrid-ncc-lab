resource "google_compute_firewall" "untrusted_iap_ssh" {
  name    = "fw-untrusted-iap-ssh"
  network = google_compute_network.untrusted.name

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["35.235.240.0/20"]
  target_service_accounts = [
    google_service_account.appliance_compute.email
  ]
}

resource "google_compute_firewall" "shared_iap_ssh" {
  name    = "fw-shared-iap-ssh"
  network = google_compute_network.shared.name

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["35.235.240.0/20"]
  target_service_accounts = [
    google_service_account.compute.email
  ]
}

resource "google_compute_firewall" "nonprod_iap_ssh" {
  name    = "fw-nonprod-iap-ssh"
  network = google_compute_network.nonprod.name

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["35.235.240.0/20"]
  target_service_accounts = [
    google_service_account.compute.email
  ]
}

resource "google_compute_firewall" "prod_iap_ssh" {
  name    = "fw-prod-iap-ssh"
  network = google_compute_network.prod.name

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["35.235.240.0/20"]
  target_service_accounts = [
    google_service_account.compute.email
  ]
}

resource "google_compute_firewall" "hub_bgp" {
  name    = "fw-hub-bgp"
  network = google_compute_network.hub.name

  allow {
    protocol = "tcp"
    ports    = [179]
  }

  source_ranges = [local.hub_subnet_cidr_range]
  target_service_accounts = [
    google_service_account.appliance_compute.email
  ]
}

resource "google_compute_firewall" "hub_icmp" {
  name    = "fw-hub-icmp"
  network = google_compute_network.hub.name

  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.0.0/8"]
  target_service_accounts = [
    google_service_account.appliance_compute.email
  ]

  dynamic "log_config" {
    for_each = var.enable_fw_log ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_firewall" "hub_appliance_any" {
  name    = "fw-hub-appliance-any"
  network = google_compute_network.hub.name

  allow {
    protocol = "all"
  }
  source_ranges = [var.peered_networks_cidr_range, local.hub_subnet_cidr_range]
  target_service_accounts = [
    google_service_account.appliance_compute.email
  ]

  dynamic "log_config" {
    for_each = var.enable_fw_log ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_firewall" "shared_icmp" {
  name    = "fw-shared-icmp"
  network = google_compute_network.shared.name

  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.0.0/8", "192.168.0.0/16"]
  target_service_accounts = [
    google_service_account.compute.email
  ]

  dynamic "log_config" {
    for_each = var.enable_fw_log ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}
