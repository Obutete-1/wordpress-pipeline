variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 Instance Connect Endpoint"
  type        = string
}

variable "security_groups" {
  description = "Security group IDs for EC2 Instance Connect Endpoint"
  type        = list(string)
}
