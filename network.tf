resource "google_compute_network" "hub" {
  name                    = "nw-hub"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true

  depends_on = [time_sleep.api_delay]
}

resource "google_compute_subnetwork" "hub_private" {
  network                  = google_compute_network.hub.id
  name                     = "sn-hub-private-${var.region}"
  private_ip_google_access = true
  region                   = var.region

  dynamic "log_config" {
    for_each = var.enable_flow_log ? [true] : []
    content {
      aggregation_interval = var.flow_log_config.aggregation_interval
      flow_sampling        = var.flow_log_config.flow_sampling
      metadata             = var.flow_log_config.metadata
    }
  }
  ip_cidr_range = local.hub_subnet_cidr_range
}

resource "google_compute_network" "transit" {
  name                    = "nw-transit"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true

  depends_on = [time_sleep.api_delay]
}

resource "google_compute_subnetwork" "transit_private" {
  network                  = google_compute_network.transit.id
  name                     = "sn-transit-private-${var.region}"
  private_ip_google_access = true
  region                   = var.region

  dynamic "log_config" {
    for_each = var.enable_flow_log ? [true] : []
    content {
      aggregation_interval = var.flow_log_config.aggregation_interval
      flow_sampling        = var.flow_log_config.flow_sampling
      metadata             = var.flow_log_config.metadata
    }
  }
  ip_cidr_range = local.transit_subnet_cidr_range
}

resource "google_compute_network" "untrusted" {
  name                    = "nw-untrusted"
  auto_create_subnetworks = false

  depends_on = [time_sleep.api_delay]
}

resource "google_compute_subnetwork" "untrusted_public" {
  network                  = google_compute_network.untrusted.id
  name                     = "sn-untrusted-public-${var.region}"
  private_ip_google_access = true
  region                   = var.region

  dynamic "log_config" {
    for_each = var.enable_flow_log ? [true] : []
    content {
      aggregation_interval = var.flow_log_config.aggregation_interval
      flow_sampling        = var.flow_log_config.flow_sampling
      metadata             = var.flow_log_config.metadata
    }
  }
  ip_cidr_range = local.untrusted_subnet_cidr_range
}

resource "google_compute_network" "prod" {
  name                    = "nw-prod"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true

  depends_on = [time_sleep.api_delay]
}

resource "google_compute_subnetwork" "prod_private" {
  network                  = google_compute_network.prod.id
  name                     = "sn-prod-private-${var.region}"
  private_ip_google_access = true
  region                   = var.region

  dynamic "log_config" {
    for_each = var.enable_flow_log ? [true] : []
    content {
      aggregation_interval = var.flow_log_config.aggregation_interval
      flow_sampling        = var.flow_log_config.flow_sampling
      metadata             = var.flow_log_config.metadata
    }
  }
  ip_cidr_range = local.prod_subnet_cidr_range
}

resource "google_compute_network" "nonprod" {
  name                    = "nw-nonprod"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true

  depends_on = [time_sleep.api_delay]
}

resource "google_compute_subnetwork" "nonprod_private" {
  network                  = google_compute_network.nonprod.id
  name                     = "sn-nonprod-private-${var.region}"
  private_ip_google_access = true
  region                   = var.region

  dynamic "log_config" {
    for_each = var.enable_flow_log ? [true] : []
    content {
      aggregation_interval = var.flow_log_config.aggregation_interval
      flow_sampling        = var.flow_log_config.flow_sampling
      metadata             = var.flow_log_config.metadata
    }
  }
  ip_cidr_range = local.nonprod_subnet_cidr_range
}

resource "google_compute_network" "shared" {
  name                    = "nw-shared"
  auto_create_subnetworks = false
  delete_default_routes_on_create = true

  depends_on = [time_sleep.api_delay]
}

resource "google_compute_subnetwork" "shared_private" {
  network                  = google_compute_network.shared.id
  name                     = "sn-shared-private-${var.region}"
  private_ip_google_access = true
  region                   = var.region

  dynamic "log_config" {
    for_each = var.enable_flow_log ? [true] : []
    content {
      aggregation_interval = var.flow_log_config.aggregation_interval
      flow_sampling        = var.flow_log_config.flow_sampling
      metadata             = var.flow_log_config.metadata
    }
  }
  ip_cidr_range = local.shared_subnet_cidr_range
}

resource "google_compute_router" "hub" {
  name    = "rtr-hub"
  network = google_compute_network.hub.name
  bgp {
    asn = var.hub_router_asn
  }
}

#resource "google_compute_router_nat" "transit" {
#  name   = "nat-transit"
#  router = google_compute_router.transit.name
#  region = google_compute_router.transit.region
#
#  nat_ip_allocate_option             = "AUTO_ONLY"
#  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"
#}