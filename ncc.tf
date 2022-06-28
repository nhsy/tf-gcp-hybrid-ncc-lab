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

# https://cloud.google.com/network-connectivity/docs/network-connectivity-center/how-to/creating-router-appliances#create-redundant-interfaces
output "ncc-bgp-config" {
  value = <<EOF
  1) Delete default routes to Default Internet gateway in peered networks manually.

  2) Enter gcloud commands below to complete setting up ncc:

  gcloud compute routers add-interface ${google_compute_router.hub.name} \
  --interface-name=rtr-hub-ncc-iface1 \
  --ip-address=${local.hub_rtr_iface1_ip_address} \
  --subnetwork=${google_compute_subnetwork.hub_private.name} \
  --region=${var.region} \
  --project=${var.project_id}

  gcloud compute routers add-interface ${google_compute_router.hub.name} \
    --interface-name=rtr-hub-ncc-iface2 \
    --ip-address=${local.hub_rtr_iface2_ip_address} \
    --subnetwork=${google_compute_subnetwork.hub_private.name} \
    --redundant-interface=rtr-hub-ncc-iface1 \
    --region=${var.region} \
    --project=${var.project_id}

  gcloud compute routers add-bgp-peer ${google_compute_router.hub.name} \
    --peer-name=rtr-hub-ncc-iface1-peer \
    --interface=rtr-hub-ncc-iface1 \
    --peer-ip-address=${google_compute_address.hub_appliance.address} \
    --peer-asn=${var.hub_appliance_asn} \
    --instance=${google_compute_instance.appliance.name} \
    --instance-zone=${local.zone} \
    --region=${var.region} \
    --advertisement-mode=CUSTOM \
    --set-advertisement-ranges=${join(",", [local.shared_subnet_cidr_range, local.nonprod_subnet_cidr_range, local.prod_subnet_cidr_range])}

  gcloud compute routers add-bgp-peer ${google_compute_router.hub.name} \
    --peer-name=rtr-hub-ncc-iface2-peer \
    --interface=rtr-hub-ncc-iface2 \
    --peer-ip-address=${google_compute_address.hub_appliance.address} \
    --peer-asn=${var.hub_appliance_asn} \
    --instance=${google_compute_instance.appliance.name} \
    --instance-zone=${local.zone} \
    --region=${var.region} \
    --advertisement-mode=CUSTOM \
    --set-advertisement-ranges=${join(",", [local.shared_subnet_cidr_range, local.nonprod_subnet_cidr_range, local.prod_subnet_cidr_range])}
  EOF
}
