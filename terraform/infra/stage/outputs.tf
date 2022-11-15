output "external_ip_address_rabbitmq" {
  value = module.rabbitmq.external_ip_address_rabbitmq
}
output "external_ip_address_mongodb" {
  value = module.mongodb.external_ip_address_mongodb
}
output "internal_ip_address_mongodb" {
  value = module.mongodb.internal_ip_address_mongodb
}
