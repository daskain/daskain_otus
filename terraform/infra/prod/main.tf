terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.76.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "rabbitmq" {
  source           = "../modules/rabbitmq"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  subnet_id        = var.subnet_id
}

module "mongodb" {
  source           = "../modules/mongodb"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  subnet_id        = var.subnet_id
}

module "gitlab" {
  source           = "../modules/gitlab"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  subnet_id        = var.subnet_id
}

resource "null_resource" "configure-k8s" {
  provisioner "local-exec" {
      command = "echo '${module.gitlab.external_ip_address_gitlab}   gitlab.otus.exp' | sed \"s/\\b\\([0-9]\\{1,3\\}\\.\\)\\{1,3\\}[0-9]\\{1,3\\}\\b/$IP/g\""
    }
}

