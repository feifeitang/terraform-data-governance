terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("gcp-joanne-tf-sa.json")

  project = "datacloud-lab"
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {
  credentials = file("gcp-joanne-tf-sa.json")

  project = "datacloud-lab"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# build sa
resource "google_service_account" "joanne_terraform_sa" {
  account_id   = "joanne-terraform"
  display_name = "joanne-terraform"
}

resource "google_service_account_key" "joanne_terraform_sa_key" {
  service_account_id = google_service_account.joanne_terraform_sa.name
}

# policy tags
resource "google_data_catalog_policy_tag" "contact_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "Contact data"
  description  = "associated with phone data"
}

resource "google_data_catalog_policy_tag" "crime_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "Crime data"
  description  = "associated with crime data"
}

resource "google_data_catalog_policy_tag" "senitive_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.my_taxonomy.id
  display_name = "Sensitive data"
  description  = "associated with identity, birth, and region data"
}

# policy tag taxonomy
resource "google_data_catalog_taxonomy" "my_taxonomy" {
  provider     = google-beta
  region       = "us"
  display_name = "terraform_taxonomy"
  # description            = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}
