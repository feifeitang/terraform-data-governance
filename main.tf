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

# service account
resource "google_service_account" "joanne_terraform_sa" {
  account_id   = "joanne-terraform"
  display_name = "joanne-terraform"
}

resource "google_service_account_key" "joanne_terraform_sa_key" {
  service_account_id = google_service_account.joanne_terraform_sa.name
}

# data policies
resource "google_bigquery_datapolicy_data_policy" "crime_policy" {
  provider         = google-beta
  location         = "us"
  data_policy_id   = "crime_policy"
  policy_tag       = google_data_catalog_policy_tag.crime_policy_tag.name
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    predefined_expression = "ALWAYS_NULL"
  }
}

resource "google_bigquery_datapolicy_data_policy" "senitive_policy" {
  provider         = google-beta
  location         = "us"
  data_policy_id   = "senitive_policy"
  policy_tag       = google_data_catalog_policy_tag.senitive_policy_tag.name
  data_policy_type = "DATA_MASKING_POLICY"
  data_masking_policy {
    predefined_expression = "ALWAYS_NULL"
  }
}

# policy tags
resource "google_data_catalog_policy_tag" "contact_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.tf_taxonomy.id
  display_name = "Contact data"
  description  = "associated with phone data"
}

resource "google_data_catalog_policy_tag" "crime_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.tf_taxonomy.id
  display_name = "Crime data"
  description  = "associated with crime data"
}

resource "google_data_catalog_policy_tag" "senitive_policy_tag" {
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.tf_taxonomy.id
  display_name = "Sensitive data"
  description  = "associated with identity, birth, and region data"
}

# policy tag taxonomy
resource "google_data_catalog_taxonomy" "tf_taxonomy" {
  provider     = google-beta
  region       = "us"
  display_name = "terraform_taxonomy"
  # description            = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}
