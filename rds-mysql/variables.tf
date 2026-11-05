variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "prefijo" {
  description = "Prefijo de los nombres de los recursos"
  type        = string
  default     = "g4-tf"
}

variable "mi_ip_cidr" {
  description = "IP desde la que se permite conectarse al puerto 3306 (ej. 190.1.2.3/32). Si se deja vacío se detecta sola."
  type        = string
  default     = ""
}

variable "usuario_admin" {
  description = "Usuario maestro de la base de datos"
  type        = string
  default     = "admin"
}
