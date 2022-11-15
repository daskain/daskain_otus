terraform {
 required_providers {
   yandex = {
     source = "yandex-cloud/yandex"
   }
 }
 required_version = ">= 0.13"
}

data "yandex_compute_image" "ubuntu-image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "mongodb" {
  name = "mongodb"
  hostname = "mongodb"
  labels = {
    tags = "mongodb"
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.image_id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  connection {
    type        = "ssh"
    host        = yandex_compute_instance.mongodb.network_interface[0].nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }
}
