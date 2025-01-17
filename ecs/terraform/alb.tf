resource "aws_lb" "1on1_alb" {
  name               = "1on1-automation-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-029fd228fb3652dff", "subnet-0ae0f2850346a980d"]

  security_groups = [
    aws_security_group.alb_sg.id,
  ]
}

resource "aws_lb_target_group" "1on1_tg" {
  name     = "1on1-automation-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "ip"  # Update this line

  health_check {
    protocol            = "HTTP"
    path                = "/health"  # Update to a valid path if needed
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "1on1_listener" {
  load_balancer_arn = aws_lb.1on1_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.1on1_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
