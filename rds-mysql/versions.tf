terraform {
  required_version = ">= 1.6"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
    http   = { source = "hashicorp/http", version = "~> 3.4" }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Proyecto = "grupo4-aurora-vs-rds"
      Curso    = "Infraestructura como Codigo - UPAO"
      Owner    = "Willian Polo"
    }
  }
}
