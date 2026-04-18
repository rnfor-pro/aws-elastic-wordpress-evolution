resource "aws_lb" "a4l_wordpress_alb" {
  name               = "A4LWORDPRESSALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_load_balancer.id]
  subnets            = [aws_subnet.sn_pub_a.id, aws_subnet.sn_pub_b.id, aws_subnet.sn_pub_c.id]
  ip_address_type    = "ipv4"

  tags = {
    Name = "A4LWORDPRESSALB"
  }
}

resource "aws_lb_target_group" "a4l_wordpress_albtg" {
  name     = "A4LWORDPRESSALBTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.a4l_vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "A4LWORDPRESSALBTG"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.a4l_wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.a4l_wordpress_albtg.arn
  }
}
