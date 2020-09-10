terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    google = {
      source = "hashicorp/google"
    }
    postgresql = {
      source = "terraform-providers/postgresql"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
