output "external_ip_address_rabbitmq" {
  value = yandex_compute_instance.rabbitmq.network_interface.0.nat_ip_address
}
