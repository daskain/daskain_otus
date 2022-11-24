output "external_ip_address_rabbitmq" {
  value = module.rabbitmq.external_ip_address_rabbitmq
}
output "external_ip_address_mongodb" {
  value = module.mongodb.external_ip_address_mongodb
}
output "external_ip_address_gitlab" {
  value = module.gitlab.external_ip_address_gitlab
}
