resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier          = "${var.project_name}-db"
  engine              = var.db_engine
  engine_version      = var.db_engine_version
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_storage_size
  storage_type        = var.db_storage_type
  db_name             = var.db_name
  username            = var.db_username
  publicly_accessible = false

  manage_master_user_password = true
  skip_final_snapshot         = true

  vpc_security_group_ids = var.security_groups
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
  }
}
