resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "A4LWORDPRESSASG"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = 600
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = [aws_subnet.sn_pub_a.id, aws_subnet.sn_pub_b.id, aws_subnet.sn_pub_c.id]
  target_group_arns         = [aws_lb_target_group.a4l_wordpress_albtg.arn]
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Wordpress-ASG"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  depends_on = [
    aws_db_instance.wordpress_db,
    aws_efs_mount_target.efs_mount_a,
    aws_efs_mount_target.efs_mount_b,
    aws_efs_mount_target.efs_mount_c,
    aws_ssm_parameter.db_user,
    aws_ssm_parameter.db_name,
    aws_ssm_parameter.db_password,
    aws_ssm_parameter.db_endpoint,
    aws_ssm_parameter.file_system_id,
    aws_ssm_parameter.alb_dns_name,
    aws_lb_listener.http
  ]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "HIGHCPU"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "LOWCPU"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "WordpressHIGHCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 40

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "WordpressLOWCPU"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 40

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}
