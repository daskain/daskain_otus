output "external_ip_address_mongodb" {
  value = yandex_compute_instance.mongodb.network_interface.0.nat_ip_address
}
output "internal_ip_address_mongodb" {
  value = yandex_compute_instance.mongodb.network_interface.0.ip_address
}
