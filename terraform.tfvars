aws_region   = "eu-west-2"
project_name = "wordpress"
environment  = "production"
vpc_cidr     = "10.0.0.0/16"

# Network variables
default-route     = "0.0.0.0/0"
loadbalancer_type = "application"

# Instance Type
ec2_instance_type = "t2.micro"
alb_instance_type = "t2.micro"

# RDS variables
db_instance_class = "db.t3.micro"
db_storage_size   = 10
db_engine_version = "8.0.37"
db_engine         = "mysql"
db_storage_type   = "gp2"
db_name           = "wordpress_db"
db_username       = "admin"

# ASG variables
min_size         = 2
max_size         = 4
desired_capacity = 2
