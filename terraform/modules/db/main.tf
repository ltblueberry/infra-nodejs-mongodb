resource "google_compute_instance" "db" {
  name         = "${var.env_name}-db"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["${var.env_name}-${var.db_tag}"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "default-allow-mongo-${var.env_name}"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["27017"]
  }

  target_tags = ["${var.env_name}-${var.db_tag}"]
  source_tags = ["${var.env_name}-${var.app_tag}"]
}
