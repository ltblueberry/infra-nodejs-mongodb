provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_storage_bucket" "terraform_state_bucket" {
  name     = "infra-nodejs-mongodb-89p13-terraform-state"
  location = "EU"
}
