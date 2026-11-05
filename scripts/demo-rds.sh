#!/usr/bin/env bash
# Demo de RDS for MySQL sobre lo que desplegó Terraform (correr desde la raíz del repo).
set -uo pipefail
cd "$(dirname "$0")/../rds-mysql"
P=$(terraform output -raw endpoint_principal)
R=$(terraform output -raw endpoint_replica)
export MYSQL_PWD=$(terraform output -raw password_admin)
ID=$(echo "$P" | cut -d. -f1)
paso(){ echo; echo "\$ $*"; }

paso "aws rds describe-db-instances (clase, motor y disco)"
aws rds describe-db-instances --query "DBInstances[?starts_with(DBInstanceIdentifier,'$ID')].[DBInstanceIdentifier,DBInstanceClass,EngineVersion,StorageType,AllocatedStorage,AvailabilityZone,ReadReplicaSourceDBInstanceIdentifier]" --output table

paso "mysql -h <principal> < sql/script.sql"
mysql -h "$P" -u admin -t < ../sql/script.sql

paso "mysql -h <replica>: SELECT y luego INSERT"
sleep 5
mysql -h "$R" -u admin -t -e "SELECT COUNT(*), @@hostname, @@read_only FROM farmacia.producto;"
mysql -h "$R" -u admin -e "INSERT INTO farmacia.producto (nombre) VALUES ('x');"

paso "aws rds reboot-db-instance (sin Multi-AZ no hay failover: la base se cae mientras reinicia)"
s=$(date +%s)
aws rds reboot-db-instance --db-instance-identifier "$ID" --query "DBInstance.DBInstanceStatus" --output text
sleep 5
aws rds wait db-instance-available --db-instance-identifier "$ID"
until mysql -h "$P" -u admin -N -e "SELECT 1" >/dev/null 2>&1; do sleep 2; done
echo ">>> Reboot: la base volvió a aceptar conexiones en $(( $(date +%s)-s )) s (medido desde la terminal)"
aws rds describe-events --source-type db-instance --source-identifier "$ID" --duration 30 --query "Events[].[Date,Message]" --output table
