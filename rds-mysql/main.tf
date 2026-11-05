resource "aws_security_group" "rds" {
  name        = "${var.prefijo}-rds-sg"
  description = "Grupo 4 - RDS for MySQL: 3306 solo desde mi IP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "MySQL desde mi IP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.mi_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia principal: aquí SÍ se elige el disco (gp3 de 20 GB).
# Los backups deben estar activos porque la réplica los necesita.
resource "aws_db_instance" "principal" {
  identifier               = "${var.prefijo}-rds"
  engine                   = "mysql"
  instance_class           = "db.t3.micro"
  allocated_storage        = 20
  storage_type             = "gp3"
  storage_encrypted        = true
  username                 = var.usuario_admin
  password                 = random_password.admin.result
  vpc_security_group_ids   = [aws_security_group.rds.id]
  publicly_accessible      = true
  backup_retention_period  = 1
  skip_final_snapshot      = true
  delete_automated_backups = true
  apply_immediately        = true
}

# Servicio complementario: réplica de lectura (se copia desde una snapshot de la principal)
resource "aws_db_instance" "replica" {
  identifier             = "${var.prefijo}-rds-replica"
  replicate_source_db    = aws_db_instance.principal.identifier
  instance_class         = "db.t3.micro"
  storage_encrypted      = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
  apply_immediately      = true
}
