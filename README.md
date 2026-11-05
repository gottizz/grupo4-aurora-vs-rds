# Grupo 4 · Amazon Aurora vs Amazon RDS for MySQL

**Infraestructura como Código – UPAO 2026**
*Base de datos optimizada para la nube frente a MySQL administrado*

Este repositorio despliega con **Terraform** los dos servicios que compara el grupo, cada uno con su
servicio complementario (la réplica de lectura). Los dos usan la misma cuenta y región y cargan el mismo
script SQL, para que la comparación sea justa.

| Stack | Qué crea | Recursos |
|---|---|---|
| [`aurora/`](aurora) | Security group (3306 solo desde mi IP) + clúster **Aurora MySQL** cifrado + **2 instancias db.t3.medium** en zonas distintas (escritora y réplica lectora) | 5 |
| [`rds-mysql/`](rds-mysql) | Security group (3306 solo desde mi IP) + instancia **RDS for MySQL db.t3.micro** con **gp3 de 20 GB** cifrado + **réplica de lectura** | 4 |

La diferencia se ve en el código: en `aurora/main.tf` **no hay disco**, porque el clúster usa un volumen
compartido que crece solo. En `rds-mysql/main.tf` hay que elegir tipo y tamaño de disco
(`storage_type = "gp3"`, `allocated_storage = 20`), y la réplica es otra instancia con su propia copia de los datos.

```
.
├── aurora/          # Terraform: clúster Aurora MySQL + 2 instancias
├── rds-mysql/       # Terraform: RDS for MySQL + réplica de lectura
├── sql/script.sql   # 10 000 productos de una farmacia (mismo script para las dos demos)
├── scripts/         # demo-aurora.sh y demo-rds.sh: uso del servicio y mediciones
└── docs/evidencias/ # capturas de la ejecución real
```

## Requisitos

- Terraform ≥ 1.6, AWS CLI v2 con credenciales configuradas (`aws configure`, región `us-east-1`).
- Cliente MySQL (`brew install mysql-client` en Mac).
- La contraseña de `admin` la genera Terraform (`random_password`) y no se guarda en el repo. El estado
  (`*.tfstate`) está en `.gitignore`.

## Cómo usarlo

```bash
# 1) Desplegar (se pueden correr los dos a la vez)
cd aurora    && terraform init && terraform apply
cd rds-mysql && terraform init && terraform apply

# 2) Usar cada servicio y medir (desde la raíz del repo)
./scripts/demo-aurora.sh   # script en la escritora, lectura e INSERT rechazado en la réplica, failover
./scripts/demo-rds.sh      # script en la principal, lectura e INSERT rechazado en la réplica, reboot

# 3) Borrar todo para no pagar de más
cd aurora    && terraform destroy
cd rds-mysql && terraform destroy
```

## Resultados medidos

RESULTADOS_AQUI

## Autor

Willian Polo ([@gottizz](https://github.com/gottizz)), Grupo 4.
