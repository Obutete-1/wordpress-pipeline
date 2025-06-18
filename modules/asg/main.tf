resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.alb_instance_type

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = 10
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = var.instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_groups
  }

  user_data = base64encode(local.userdata_script)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-instance"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = [var.target_group_arn]
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg"
    propagate_at_launch = true
  }
}

# Get Instances Created by ASG
data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.main.name]
  }
}
