# Red: se usa la VPC por defecto y un security group que solo deja entrar a mi IP por el 3306
data "aws_vpc" "default" {
  default = true
}

data "http" "mi_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  mi_ip = var.mi_ip_cidr != "" ? var.mi_ip_cidr : "${chomp(data.http.mi_ip.response_body)}/32"
}

resource "random_password" "admin" {
  length           = 20
  special          = true
  override_special = "_-+="
}
