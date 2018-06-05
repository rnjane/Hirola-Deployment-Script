data "google_compute_zones" "available" {}

resource "google_compute_instance" "hirola-instance" {
  project      = "${var.project}"
  zone         = "${var.zone}"
  name         = "${var.env}-hirola"
  machine_type = "f1-micro"
  tags         = ["hirola"]

  boot_disk {
    initialize_params {
      image = "hirola-base-image"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${var.ip-address}"
    }
  }

  metadata_startup_script = "${file("deploy_hirola.sh")}"

  metadata {
    ipAddress    = "${var.ip-address}"
    circleBranch = "${var.branch}"
    host         = "${var.host}"
    env          = "${var.env}"
    environment  = "${var.environment}"
    databaseName = "${var.database_name}"
    user         = "${var.database_user}"
    password     = "${var.database_password}"
    postgresIp   = "${var.postgres_ip}"
    gsBucketName = "${var.gs_bucket_name}"
    gsBucketURL  = "${var.gs_bucket_url}"
  }

  service_account {
    scopes = ["storage-full"]
  }
}
