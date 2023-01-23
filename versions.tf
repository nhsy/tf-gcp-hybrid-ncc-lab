terraform {
  required_version = ">=1.2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.49.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}