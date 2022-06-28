resource "google_compute_address" "hub_appliance" {
  name         = "hub-private-appliance"
  subnetwork   = google_compute_subnetwork.hub_private.id
  address_type = "INTERNAL"
  address      = cidrhost(local.hub_subnet_cidr_range, 20)
}

resource "google_compute_address" "untrusted_appliance" {
  name         = "untrusted-public-appliance"
  subnetwork   = google_compute_subnetwork.untrusted_public.id
  address_type = "INTERNAL"
  address      = cidrhost(local.untrusted_subnet_cidr_range, 20)
}

resource "google_compute_instance" "appliance" {
  name         = "vm-appliance"
  machine_type = "g1-small"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  can_ip_forward = true

  #nic0 - untrusted
  network_interface {
    network    = google_compute_network.untrusted.self_link
    subnetwork = google_compute_subnetwork.untrusted_public.self_link
    network_ip = google_compute_address.untrusted_appliance.address
    access_config {
      // Ephemeral public IP
    }
  }
  #nic1 - transit
  network_interface {
    network    = google_compute_network.hub.self_link
    subnetwork = google_compute_subnetwork.hub_private.self_link
    network_ip = google_compute_address.hub_appliance.address
  }

  metadata_startup_script = templatefile("files/appliance.sh",
    {
      router_id = google_compute_address.hub_appliance.address,
      hub_ip    = google_compute_address.hub_appliance.address,
      hub_gw    = google_compute_subnetwork.hub_private.gateway_address,
      local_asn = var.hub_appliance_asn,
      peer_asn  = var.hub_router_asn,
      peer_ip1  = local.hub_rtr_iface1_ip_address,
      peer_ip2  = local.hub_rtr_iface2_ip_address,
    }
  )

  service_account {
    email  = google_service_account.appliance_compute.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_address" "shared_test" {
  name         = "shared-private-test"
  subnetwork   = google_compute_subnetwork.shared_private.id
  address_type = "INTERNAL"
  address      = cidrhost(local.shared_subnet_cidr_range, 20)
}

resource "google_compute_address" "nonprod_test" {
  name         = "nonprod-private-test"
  subnetwork   = google_compute_subnetwork.nonprod_private.id
  address_type = "INTERNAL"
  address      = cidrhost(local.nonprod_subnet_cidr_range, 20)
}

resource "google_compute_address" "prod_test" {
  name         = "prod-private-test"
  subnetwork   = google_compute_subnetwork.prod_private.id
  address_type = "INTERNAL"
  address      = cidrhost(local.prod_subnet_cidr_range, 20)
}

resource "google_compute_instance" "shared_test" {
  name         = "vm-shared-test"
  machine_type = "f1-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.shared.self_link
    subnetwork = google_compute_subnetwork.shared_private.self_link
    network_ip = google_compute_address.shared_test.address
  }

  service_account {
    email  = google_service_account.compute.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "nonprod_test" {
  name         = "vm-nonprod-test"
  machine_type = "f1-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.nonprod.self_link
    subnetwork = google_compute_subnetwork.nonprod_private.self_link
    network_ip = google_compute_address.nonprod_test.address
  }

  service_account {
    email  = google_service_account.compute.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "prod_test" {
  name         = "vm-prod-test"
  machine_type = "f1-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.prod.self_link
    subnetwork = google_compute_subnetwork.prod_private.self_link
    network_ip = google_compute_address.prod_test.address
  }

  service_account {
    email  = google_service_account.compute.email
    scopes = ["cloud-platform"]
  }
}
