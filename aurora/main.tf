resource "aws_security_group" "aurora" {
  name        = "${var.prefijo}-aurora-sg"
  description = "Grupo 4 - Aurora MySQL: 3306 solo desde mi IP"
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

# Clúster: aquí NO se elige disco ni tamaño. El volumen es compartido,
# guarda 6 copias en 3 zonas y crece solo.
resource "aws_rds_cluster" "this" {
  cluster_identifier      = "${var.prefijo}-aurora"
  engine                  = "aurora-mysql"
  master_username         = var.usuario_admin
  master_password         = random_password.admin.result
  vpc_security_group_ids  = [aws_security_group.aurora.id]
  storage_encrypted       = true
  backup_retention_period = 1
  skip_final_snapshot     = true
  apply_immediately       = true
}

# Servicio complementario: 2 instancias en zonas distintas.
# La primera que se crea es la escritora y la otra queda como réplica lectora.
resource "aws_rds_cluster_instance" "this" {
  count               = 2
  identifier          = "${var.prefijo}-aurora-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.this.id
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version
  instance_class      = "db.t3.medium"
  publicly_accessible = true
  availability_zone   = sort(tolist(aws_rds_cluster.this.availability_zones))[count.index]
  promotion_tier      = count.index
  apply_immediately   = true
}
