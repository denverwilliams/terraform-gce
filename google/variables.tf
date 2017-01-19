variable "gce_project_name" {
  description = "Name of your existing GCE project"
  default = ""
}

variable "gce_region" {
  description = "Region to run GCE instances in"
  default = "us-central1"
}

variable "gce_zone" {
  description = "Zone to run GCE instances in"
  default = "us-central1-a"
}

variable "gce_key_path" {
  description = "Path to private SSH key for the GCE instances"
  default = "~/.ssh/google_compute_engine"
}

variable "gce_coreos_disk_image" {
  description = "Name of CoreOS Root disk image for the GCE instances to use"
  default = "coreos-stable-1235-6-0-v20170111"
}

variable "gce_machine_type" {
  description = "Type of instance ot use in GCE"
  default = "n1-standard-1"
}
