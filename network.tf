resource "google_compute_firewall" "hirola-firewall" {
  name    = "${var.env}-hirola-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "8000", "8080", "3000", "22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["hirola"]
}
