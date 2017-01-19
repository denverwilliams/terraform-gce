output "gce_instances" {
  value = "GCE instances:\n - ${join("\n - ", google_compute_instance.iicloud.*.network.0.external_address)}"
}
