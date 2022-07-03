
data "aws_ami" "amznlx2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "ec2_launcher" {
  name_prefix                 = "alb-launcher"
  image_id                    = data.aws_ami.amznlx2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  security_groups             = [aws_security_group.appserver-security-group2.id]
  user_data                   = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_scaling_rule1" {
  name                 = "app-scaling"
  vpc_zone_identifier  = [aws_subnet.private_subnet1a.id, aws_subnet.private_subnet1b.id]
  launch_configuration = aws_launch_configuration.ec2_launcher.name
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  lifecycle {
    create_before_destroy = true
  }


  tag {
    key                 = "Name"
    value               = "app-tier"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}

resource "aws_lb" "app" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.appelb_http.id]
  subnets            = [aws_subnet.public_subnet1a.id, aws_subnet.public_subnet2b.id]
  tags = {
    "Name" = "APP"
  }
}

resource "aws_lb_target_group" "app_target_group1" {
  name     = "app-target-group1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
#    health_check {
#         unhealthy_threshold = 3
#         healthy_threshold = 10
#         timeout = 5
#         interval = 30
#         path = "/"
#         port = "traffic-port"
#         matcher = "200-320" #success codes
#     }
 }

resource "aws_lb_listener" "lb_listener1" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group1.arn
  }
}
resource "aws_lb_listener_rule" "lb_listener1_rule_config" {
  listener_arn = aws_lb_listener.lb_listener1.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group1.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}

resource "aws_autoscaling_attachment" "alb_asg_attach1" {
  autoscaling_group_name = aws_autoscaling_group.app_scaling_rule1.id
  alb_target_group_arn   = aws_lb_target_group.app_target_group1.arn
}

resource "aws_autoscaling_policy" "app_policy_up" {
  name                   = "app_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_scaling_rule1.name
}
resource "aws_cloudwatch_metric_alarm" "app_cpu_alarm_up" {
  alarm_name          = "app_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_scaling_rule1.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.app_policy_up.arn]
}
resource "aws_autoscaling_policy" "app_policy_down" {
  name                   = "app_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_scaling_rule1.name
}
resource "aws_cloudwatch_metric_alarm" "app_cpu_alarm_down" {
  alarm_name          = "app_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_scaling_rule1.name
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.app_policy_down.arn]
}