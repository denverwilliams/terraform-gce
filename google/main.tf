// Declare and provision 3 GCE instances
resource "google_compute_instance" "iicloud" {
    count = 1
    // By default (see variables.tf), these are going to be of type 'n1-standard-1' in zone 'us-central1-a'.
    machine_type = "${var.gce_machine_type}"
    zone = "${var.gce_zone}"

    // Ensure clear host naming scheme, which results in functional native DNS within GCE
    name = "iicloud-gce-${count.index}" // => `iicloud-gce-{0,1,2}`

    // Attach an alpha image of CoreOS as the primary disk
    disk {
        image = "${var.gce_coreos_disk_image}"
    }

    // Attach to a network with some custom firewall rules and static IPs (details further down)
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
    }

    // Provisioning

    // 1. Cloud Config phase writes systemd unit definitions and only starts two host-independent units —
    // `pre-fetch-container-images.service` and `install-iicloud.service`
    metadata {
      user-data = "${file("hanlon-api-cloud-config.yml")}"
    }
}

resource "google_compute_instance" "iicloud-node" {
    count = 1
    // By default (see variables.tf), these are going to be of type 'n1-standard-1' in zone 'us-central1-a'.
    machine_type = "${var.gce_machine_type}"
    zone = "${var.gce_zone}"
 
    // Ensure clear host naming scheme, which results in functional native DNS within GCE
    name = "iicloud-node-${count.index}" // => `iicloud-gce-{0,1,2}`

    // Attach an alpha image of CoreOS as the primary disk
    disk {
        image = "${var.gce_coreos_disk_image}"
    }

    // Attach to a network with some custom firewall rules and static IPs (details further down)
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
    }

    // Provisioning

    // 1. Cloud Config phase writes systemd unit definitions and only starts two host-independent units —
    // `pre-fetch-container-images.service` and `install-iicloud.service`
    metadata {
      user-data = "${file("ii-node-cloud-config.yml")}"
    }
}
