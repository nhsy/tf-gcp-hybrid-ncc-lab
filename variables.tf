variable "project_id" {
  description = "Project ID to deploy into"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "europe-west1"

  validation {
    condition     = can(regex("(europe-west1|europe-west2|us-central1)", var.region))
    error_message = "The region must be one of: europe-west1, europe-west2, us-central1."
  }
}

variable "enable_flow_log" {
  type     = bool
  default  = true
  nullable = false
}

variable "enable_fw_log" {
  type     = bool
  default  = true
  nullable = false
}

variable "flow_log_config" {
  description = "VPC flow log configuration, as per google_compute_subnetwork resource docs."
  default = {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  nullable = false
}

# Hub       - 10.64.0.0/16
# Transit   - 10.65.0.0/16
# Untrusted - 10.66.0.0/16
# Shared    - 10.72.0.0/16
# Nonprod   - 10.73.0.0/16
# Prod      - 10.74.0.0/16

variable "hub_cidr_range" {
  default = "10.64.0.0/16"
  type    = string
}

variable "transit_cidr_range" {
  default = "10.65.0.0/16"
  type    = string
}

variable "untrusted_cidr_range" {
  default = "10.66.0.0/16"
  type    = string
}

variable "shared_cidr_range" {
  default = "10.72.0.0/16"
  type    = string
}

variable "nonprod_cidr_range" {
  default = "10.73.0.0/16"
  type    = string
}

variable "prod_cidr_range" {
  default = "10.74.0.0/16"
  type    = string
}

variable "hub_router_asn" {
  default = "65100"
  type    = string
}

variable "hub_appliance_asn" {
  default = "65200"
  type    = string
}

variable "create_ncc" {
  default = true
  type    = bool
}