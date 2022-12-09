terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("gcp-tf-sa.json")

  project = "datacloud-lab"
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {
  credentials = file("gcp-tf-sa.json")

  project = "datacloud-lab"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# build sa
resource "google_service_account" "joanneterraformsa" {
  account_id   = "joanne-terraform"
  display_name = "joanne-terraform"
}

resource "google_service_account_key" "joanneterraformsakey" {
  service_account_id = google_service_account.joanneterraformsa.name
}

resource "google_data_catalog_policy_tag" "basic_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "Low security"
  description  = "A policy tag normally associated with low security items"
}

resource "google_data_catalog_taxonomy" "my_taxonomy" {
  provider               = google-beta
  region                 = "us"
  display_name           = "taxonomy_display_name"
  description            = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}
