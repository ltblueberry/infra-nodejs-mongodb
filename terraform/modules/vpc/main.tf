resource "google_compute_firewall" "firewall_ssh" {
  name        = "default-allow-ssh-${var.env_name}"
  network     = "default"
  description = "Allow SSH for ${var.env_name} environment"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_ranges}"
  target_tags   = ["${var.env_name}-${var.app_tag}", "${var.env_name}-${var.db_tag}"]
}
