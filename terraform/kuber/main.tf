terraform {
 required_providers {
   yandex = {
     source = "yandex-cloud/yandex"
   }
 }
 required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_vpc_network" "k8s-net" {
  name = "k8s-network"
}


resource "yandex_vpc_subnet" "k8s-yc-subnet" {
  name           = "k8s-yc-subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s-net.id
  v4_cidr_blocks = [var.ip_range]

}

resource "yandex_kubernetes_cluster" "k8s-yc" {
  name        = "k8s-yc"
  description = "k8s-yc"
  network_id     = yandex_vpc_network.k8s-net.id

  master {
    version = "1.20"
    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.k8s-yc-subnet.id
    }

    public_ip = true

    }
  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id

  labels = {
    env       = "test"
  }

  release_channel = "RAPID"
  network_policy_provider = "CALICO"

}


resource "yandex_kubernetes_node_group" "k8s-yc-node" {
  cluster_id  = yandex_kubernetes_cluster.k8s-yc.id
  name        = "k8s-yc-node"
  description = "k8s-yc-node"
  version     = "1.20"

  labels = {
    env = "test"
  }

  instance_template {
    platform_id = "standard-v2"
    nat                = true


    resources {
      memory = 8
      cores  = 4
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    metadata = {
      ssh-keys = "kuber:${file(var.public_key_path)}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "kuber"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }


}
