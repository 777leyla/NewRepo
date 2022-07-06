resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_http.id]
  subnets            = [aws_subnet.public_subnet1a.id, aws_subnet.public_subnet2b.id]
  tags = {
    "Name" = "WEB"
  }
}

resource "aws_launch_configuration" "ec2_launcher1" {
  name_prefix                 = "web-alb-launcher"
  image_id                    = data.aws_ami.amznlx2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  security_groups             = [aws_security_group.webserver-security-group2.id]
  user_data                   = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "web-scaling-rule" {
  name                 = "ec2-scaling1"
  vpc_zone_identifier  = [aws_subnet.private_subnet1a.id, aws_subnet.private_subnet1b.id]
  launch_configuration = aws_launch_configuration.ec2_launcher1.name
  desired_capacity     = 2
  max_size             = 6
  min_size             = 2
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "web-tier"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }

}
resource "aws_lb_target_group" "ec2_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_target_group.arn
  }
}

resource "aws_autoscaling_attachment" "alb_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.web-scaling-rule.id
  lb_target_group_arn   = aws_lb_target_group.ec2_target_group.arn
}

resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web-scaling-rule.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-scaling-rule.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
}
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web-scaling-rule.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-scaling-rule.name
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_down.arn]
}


# resource "aws_lb" "web" {
#   name               = "web-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.elb_http.id]
#   subnets            = [aws_subnet.public_subnet1a.id, aws_subnet.public_subnet2b.id]
#   tags = {
#     "Name" = "WEB"
#   }
# }

# resource "aws_launch_template" "ec2_launcher1" {
#   name                = "web-launcher"
#   image_id                    = data.aws_ami.amznlx2.id
#   instance_type               = "t2.micro"
#   key_name                    = "gogreen"
#   iam_instance_profile {
#   #name = aws_instance_profile.bastion_profile.name
#   }
#   user_data = filebase64("user_data.sh")
#  network_interfaces {
#    security_groups = [aws_security_group.webserver-security-group2.id]
#  }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_group" "web_scaling_rule1" {
#   name                 = "web-scaling"
#   vpc_zone_identifier  = [aws_subnet.private_subnet1a.id, aws_subnet.private_subnet1b.id]
#   launch_template {
#     id = aws_launch_template.ec2_launcher1.id
#     version = "$Latest"
#   }
#   desired_capacity     = 2
#   max_size             = 6
#   min_size             = 2
#   health_check_type         = "EC2"

  
#   lifecycle {
#     create_before_destroy = true
#   }


#   tag {
#     key                 = "Name"
#     value               = "web-tier"
#     propagate_at_launch = "true"
#   }
#   tag {
#     key                 = "lorem"
#     value               = "ipsum"
#     propagate_at_launch = false
#   }
#  target_group_arns = [aws_lb_target_group.web_target_group.arn]
# }


# # resource "aws_autoscaling_group" "web-scaling-rule" {
# #   name                 = "ec2-scaling1"
# #   vpc_zone_identifier  = [aws_subnet.private_subnet2a.id, aws_subnet.private_subnet2b.id]
# #   launch_configuration = aws_launch_configuration.ec2_launcher1.name
# #   desired_capacity     = 2
# #   max_size             = 6
# #   min_size             = 2
# #   health_check_grace_period = 300
# #   health_check_type         = "ELB"
# #   lifecycle {
# #     create_before_destroy = true
# #   }
# #   tag {
# #     key                 = "Name"
# #     value               = "web-tier"
# #     propagate_at_launch = "true"
# #   }
# #   tag {
# #     key                 = "lorem"
# #     value               = "ipsum"
# #     propagate_at_launch = false
# #   }

# # }
# resource "aws_lb_target_group" "web_target_group" {
#   name     = "web-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id
#       health_check {

#     interval            = 10
#     path                = "/index.php"
#     port                = 80
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 5
#     protocol            = "HTTP"

#   }
# }
# resource "aws_lb_listener" "lb_listener" {
#   load_balancer_arn = aws_lb.web.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web_target_group.arn
#   }
# }
# # resource "aws_lb_listener_rule" "lb_listener_rule_config" {
# #   listener_arn = aws_lb_listener.lb_listener.arn
# #   priority     = 100

# #   action {
# #     type             = "forward"
# #     target_group_arn = aws_lb_target_group.web_target_group.arn
# #   }

# #   condition {
# #     path_pattern {
# #       values = ["/static/*"]
# #     }
# #   }
# # }
# resource "aws_autoscaling_attachment" "web_asg_attach" {
#   autoscaling_group_name = aws_autoscaling_group.web_scaling_rule1.id
#    lb_target_group_arn   = aws_lb_target_group.web_target_group.arn
# }

# resource "aws_autoscaling_policy" "web_policy_up" {
#   name                   = "web_policy_up"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.web_scaling_rule1.id
# }
# resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
#   alarm_name          = "web_cpu_alarm_up"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "60"

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web_scaling_rule1.name
#   }

#   alarm_description = "This metric monitor EC2 instance CPU utilization"
#   alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
# }
# resource "aws_autoscaling_policy" "web_policy_down" {
#   name                   = "web_policy_down"
#   scaling_adjustment     = -1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.web_scaling_rule1.name
# }
# resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
#   alarm_name          = "web_cpu_alarm_down"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "10"

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web_scaling_rule1.name
#   }
#   alarm_description = "This metric monitor EC2 instance CPU utilization"
#   alarm_actions     = [aws_autoscaling_policy.web_policy_down.arn]
# }