terraform {
  required_version = ">=1.2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.26.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7.2"
    }
    #    google-beta = {
    #      source  = "hashicorp/google-beta"
    #      version = "~> 4.26.0"
    #    }
    #    null = {
    #      source = "hashicorp/time"
    #      // version = "~> 0.7"
    #    }
  }
}