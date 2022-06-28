data "google_compute_zones" "available" {}

locals {
  zone = data.google_compute_zones.available.names[0]

  hub_subnet_cidr_range       = cidrsubnet(var.hub_cidr_range, 8, 1)
  transit_subnet_cidr_range   = cidrsubnet(var.transit_cidr_range, 8, 1)
  untrusted_subnet_cidr_range = cidrsubnet(var.untrusted_cidr_range, 8, 1)
  nonprod_subnet_cidr_range   = cidrsubnet(var.nonprod_cidr_range, 8, 1)
  prod_subnet_cidr_range      = cidrsubnet(var.prod_cidr_range, 8, 1)
  shared_subnet_cidr_range    = cidrsubnet(var.shared_cidr_range, 8, 1)

  hub_rtr_iface1_ip_address = cidrhost(local.hub_subnet_cidr_range, 10)
  hub_rtr_iface2_ip_address = cidrhost(local.hub_subnet_cidr_range, 11)

}
