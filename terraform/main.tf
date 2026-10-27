terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Medallion datasets for the BigQuery production path.
# Bronze holds raw source tables; silver holds staging + intermediate;
# gold holds dimensions, facts, and marts.
resource "google_bigquery_dataset" "bronze" {
  dataset_id = "lakehouse_bronze"
  location   = var.region
}

resource "google_bigquery_dataset" "silver" {
  dataset_id = "lakehouse_silver"
  location   = var.region
}

resource "google_bigquery_dataset" "gold" {
  dataset_id = "lakehouse_gold"
  location   = var.region
}

# NOTE: Cloud Composer is intentionally NOT created here. It is the most
# expensive piece of this project. Create it only when testing the DAG in
# orchestration/dags/, and delete it right after.
