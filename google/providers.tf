provider "google" {
  credentials = "${file("credentials.json")}"
  project = "${var.gce_project_name}"
  region = "${var.gce_region}"
}
