# All resources related to the Airflow metadata database.
# The database is not publicly accessible via the Internet. Only from the VPC.
# The database master user password is managed by AWS Secrets Manager.

# Create the database subnet group
resource "aws_db_subnet_group" "airflow_db_subnet_group" {
  name       = "airflow-db-subnet-group-${local.deployment_id}"
  subnet_ids = local.airflow_vpc_subnets_ids
}

# Database security group
resource "aws_security_group" "airflow_db_security_group" {
  name        = "airflow-db-sg-${local.deployment_id}"
  description = "Allows access to the database from the VPC on TCP port 5432 (postgres)"
  vpc_id      = local.airflow_vpc_id

  ingress {
    description = "Allows access to the database from the VPC on TCP port 5432 (postgres)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [local.airflow_vpc_cidr_block]
  }

  egress {
    description = "Allows outbound access anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }
}

resource "aws_db_instance" "airflow_db" {
  identifier            = "airflow-db-${local.deployment_id}"
  engine                = "postgres"
  engine_version        = "14"          # or whichever version AWS Academy allows
  instance_class        = "db.t3.micro" # smallest allowed in Academy
  allocated_storage     = 20
  max_allocated_storage = 100

  db_subnet_group_name   = aws_db_subnet_group.airflow_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.airflow_db_security_group.id]

  db_name                     = "airflow"
  username                    = "postgres"
  manage_master_user_password = true

  multi_az            = false
  publicly_accessible = false

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = true
}
