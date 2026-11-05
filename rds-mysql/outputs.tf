output "endpoint_principal" {
  value = aws_db_instance.principal.address
}

output "endpoint_replica" {
  value = aws_db_instance.replica.address
}

output "instancias" {
  value = {
    (aws_db_instance.principal.identifier) = "${aws_db_instance.principal.availability_zone} · ${aws_db_instance.principal.instance_class} · ${aws_db_instance.principal.storage_type} ${aws_db_instance.principal.allocated_storage} GB"
    (aws_db_instance.replica.identifier)   = "${aws_db_instance.replica.availability_zone} · ${aws_db_instance.replica.instance_class} · réplica de ${aws_db_instance.principal.identifier}"
  }
}

output "security_group" {
  value = "${aws_security_group.rds.id} (3306 desde ${local.mi_ip})"
}

output "password_admin" {
  value     = random_password.admin.result
  sensitive = true
}
