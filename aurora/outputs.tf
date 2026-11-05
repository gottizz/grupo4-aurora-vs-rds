output "endpoint_escritor" {
  description = "Endpoint del clúster: siempre apunta a la instancia escritora"
  value       = aws_rds_cluster.this.endpoint
}

output "endpoint_lector" {
  description = "Endpoint de lectura: reparte las consultas entre las réplicas"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "instancias" {
  value = { for i in aws_rds_cluster_instance.this : i.identifier => i.availability_zone }
}

output "security_group" {
  value = "${aws_security_group.aurora.id} (3306 desde ${local.mi_ip})"
}

output "password_admin" {
  value     = random_password.admin.result
  sensitive = true
}
