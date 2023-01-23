resource "google_network_connectivity_hub" "hub" {
  count   = var.create_ncc ? 1 : 0
  name    = "ncc-hub"
  project = var.project_id

  depends_on = [time_sleep.api_delay]
}

resource "google_network_connectivity_spoke" "hub_appliance" {
  count    = var.create_ncc ? 1 : 0
  name     = "hub-appliance-fw1"
  location = var.region
  hub      = google_network_connectivity_hub.hub[0].id

  linked_router_appliance_instances {
    instances {
      virtual_machine = google_compute_instance.appliance.self_link
      ip_address      = google_compute_address.hub_appliance.address
    }
    site_to_site_data_transfer = false
  }
}

resource "google_compute_router_interface" "primary" {
  name               = "rtr-hub-ncc-primary"
  region             = google_compute_router.hub.region
  router             = google_compute_router.hub.name
  subnetwork         = google_compute_subnetwork.hub_private.self_link
  private_ip_address = local.hub_rtr_primary_ip_address
}

resource "google_compute_router_interface" "secondary" {
  name                = "rtr-hub-ncc-redundant"
  region              = google_compute_router.hub.region
  router              = google_compute_router.hub.name
  subnetwork          = google_compute_subnetwork.hub_private.self_link
  private_ip_address  = local.hub_rtr_secondary_ip_address
  redundant_interface = google_compute_router_interface.primary.name
}

resource "google_compute_router_peer" "primary" {
  name                      = "rtr-hub-ncc-primary-peer"
  router                    = google_compute_router.hub.name
  region                    = google_compute_router.hub.region
  interface                 = google_compute_router_interface.primary.name
  router_appliance_instance = google_compute_instance.appliance.self_link
  peer_asn                  = var.hub_appliance_asn
  peer_ip_address           = google_compute_address.hub_appliance.address
  advertise_mode            = "CUSTOM"

  dynamic "advertised_ip_ranges" {
    for_each = toset([local.shared_subnet_cidr_range, local.nonprod_subnet_cidr_range, local.prod_subnet_cidr_range])
    content {
      range = advertised_ip_ranges.value
    }
  }
}

resource "google_compute_router_peer" "secondary" {
  name                      = "rtr-hub-ncc-secondary-peer"
  router                    = google_compute_router.hub.name
  region                    = google_compute_router.hub.region
  interface                 = google_compute_router_interface.secondary.name
  router_appliance_instance = google_compute_instance.appliance.self_link
  peer_asn                  = var.hub_appliance_asn
  peer_ip_address           = google_compute_address.hub_appliance.address
  advertise_mode            = "CUSTOM"

  dynamic "advertised_ip_ranges" {
    for_each = toset([local.shared_subnet_cidr_range, local.nonprod_subnet_cidr_range, local.prod_subnet_cidr_range])
    content {
      range = advertised_ip_ranges.value
    }
  }
}
