variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_size" {
  description = "Minimum size for ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum size for ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ASG"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of target group"
  type        = string
}

variable "instance_profile" {
  description = "IAM Instance Profile"
  type        = string
}
