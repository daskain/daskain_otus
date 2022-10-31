variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable subnet_id {
  description = "Subnet"
}
variable service_account_key_file {
  description = "key.json"
}
variable service_account_id {
  description = "service account id"
}
variable iam_user {
  description = "service user"
}
variable ip_range {
  description = "IP Range for Network"
  default = "10.244.0.0/16"
  type = string
}
