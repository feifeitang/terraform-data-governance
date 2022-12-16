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

# policy tag taxonomy
resource "google_data_catalog_taxonomy" "tf_taxonomy" {
  provider     = google-beta
  region       = "us"
  display_name = "terraform_taxonomy"
  # description            = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
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

# # bigquery table
# resource "google_bigquery_dataset" "tf_dataset" {
#   dataset_id                  = "terraform_demo"
#   location                    = "US"
#   default_table_expiration_ms = 3600000

#   labels = {
#     env = "default"
#   }
# }

# resource "google_bigquery_table" "mock" {
#   dataset_id = google_bigquery_dataset.tf_dataset.dataset_id
#   table_id   = "mock_data"

#   # labels = {
#   #   env = "terraform_demo"
#   # }

#   schema = <<EOF
# [
#   {
#     "name": "int64_field_0",
#     "type": "INTEGER",
#     "mode": "NULLABLE",
#   },
#   {
#     "name": "id",
#     "type": "INTEGER",
#     "mode": "NULLABLE",
#     "description": "id"
#   },
#   {
#     "name": "name",
#     "type": "STRING",
#     "mode": "NULLABLE",
#     "description": "name"
#   },
#   {
#     "name": "identity",
#     "type": "STRING",
#     "mode": "NULLABLE",
#     "description": "identity",
#     "policyTags": {
#       "names": [
#         "${google_data_catalog_policy_tag.senitive_policy_tag.id}"
#       ]
#     }
#   },
#   {
#     "name": "birth",
#     "type": "DATE",
#     "mode": "NULLABLE",
#     "description": "birth"
#   },
#   {
#     "name": "phone",
#     "type": "INTEGER",
#     "mode": "NULLABLE",
#     "description": "phone"
#   },
#   {
#     "name": "region",
#     "type": "STRING",
#     "mode": "NULLABLE",
#     "description": "region"
#   },
#   {
#     "name": "crime",
#     "type": "BOOLEAN",
#     "mode": "NULLABLE",
#     "description": "crime"
#   }
# ]
# EOF

#   # external_data_configuration {
#   #   autodetect    = false
#   #   source_format = "CSV"

#   #   csv_options {
#   #     quote = ""
#   #   }

#   #   source_uris = [
#   #     "https://storage.cloud.google.com/chi110356042/mock1212.csv"
#   #   ]
#   # }

# }
