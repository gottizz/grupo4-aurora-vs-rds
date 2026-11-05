#!/usr/bin/env bash
# Demo de Aurora MySQL sobre lo que desplegó Terraform (correr desde la raíz del repo).
# Requiere: AWS CLI, cliente mysql y haber hecho `terraform apply` en aurora/.
set -uo pipefail
cd "$(dirname "$0")/../aurora"
W=$(terraform output -raw endpoint_escritor)
R=$(terraform output -raw endpoint_lector)
export MYSQL_PWD=$(terraform output -raw password_admin)
CL=$(terraform output -raw endpoint_escritor | cut -d. -f1)
paso(){ echo; echo "\$ $*"; }

paso "aws rds describe-db-clusters (miembros y roles)"
aws rds describe-db-clusters --db-cluster-identifier "$CL" --query "DBClusters[0].{Motor:EngineVersion,Storage:StorageType,Miembros:DBClusterMembers[].[DBInstanceIdentifier,IsClusterWriter]}" --output json

paso "mysql -h <escritor> < sql/script.sql"
mysql -h "$W" -u admin -t < ../sql/script.sql

paso "mysql -h <lector>: SELECT y luego INSERT"
mysql -h "$R" -u admin -t -e "SELECT COUNT(*), @@hostname, @@read_only FROM farmacia.producto;"
mysql -h "$R" -u admin -e "INSERT INTO farmacia.producto (nombre) VALUES ('x');"

paso "aws rds failover-db-cluster (y esperar a que cambie la escritora)"
antes=$(aws rds describe-db-clusters --db-cluster-identifier "$CL" --query "DBClusters[0].DBClusterMembers[?IsClusterWriter].DBInstanceIdentifier" --output text)
s=$(date +%s)
aws rds failover-db-cluster --db-cluster-identifier "$CL" --query "DBCluster.Status" --output text
while :; do
  ahora=$(aws rds describe-db-clusters --db-cluster-identifier "$CL" --query "DBClusters[0].DBClusterMembers[?IsClusterWriter].DBInstanceIdentifier" --output text)
  [ "$ahora" != "$antes" ] && break; sleep 2
done
echo ">>> Escritora: $antes -> $ahora en $(( $(date +%s)-s )) s (medido desde la terminal)"
sleep 20
aws rds describe-events --source-type db-cluster --source-identifier "$CL" --duration 30 --query "Events[].[Date,Message]" --output table
aws rds describe-db-clusters --db-cluster-identifier "$CL" --query "DBClusters[0].DBClusterMembers[].[DBInstanceIdentifier,IsClusterWriter]" --output table
