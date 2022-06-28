# Hub to Target Peerings
resource "google_compute_network_peering" "hub_shared" {
  name                 = "hub-shared"
  network              = google_compute_network.hub.self_link
  peer_network         = google_compute_network.shared.self_link
  export_custom_routes = true
}

resource "google_compute_network_peering" "hub_nonprod" {
  name                 = "hub-nonprod"
  network              = google_compute_network.hub.self_link
  peer_network         = google_compute_network.nonprod.self_link
  export_custom_routes = true
}

resource "google_compute_network_peering" "hub_prod" {
  name                 = "hub-prod"
  network              = google_compute_network.hub.self_link
  peer_network         = google_compute_network.prod.self_link
  export_custom_routes = true
}

# Target to Hub Peerings
resource "google_compute_network_peering" "shared_hub" {
  name                 = "shared-hub"
  network              = google_compute_network.shared.self_link
  peer_network         = google_compute_network.hub.self_link
  import_custom_routes = true
}

resource "google_compute_network_peering" "nonprod_hub" {
  name                 = "nonprod-hub"
  network              = google_compute_network.nonprod.self_link
  peer_network         = google_compute_network.hub.self_link
  import_custom_routes = true
}

resource "google_compute_network_peering" "prod_hub" {
  name                 = "prod-hub"
  network              = google_compute_network.prod.self_link
  peer_network         = google_compute_network.hub.self_link
  import_custom_routes = true
}