# Instance Target Group — for the legacy EC2 application
resource "aws_lb_target_group" "instance_tg" {
  name        = "tg-instance-legacy-app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.instance_tg.arn
  target_id        = var.ec2_instance_id
  port             = 80
}

# Lambda Target Group — for the new feature
resource "aws_lb_target_group" "lambda_tg" {
  name        = "tg-lambda-new-feature"
  target_type = "lambda"

  # Health checks must be disabled for Lambda target groups
  health_check {
    enabled = false
  }
}

resource "aws_lb_target_group_attachment" "lambda_attachment" {
  target_group_arn = aws_lb_target_group.lambda_tg.arn
  target_id        = var.lambda_function_arn
  depends_on       = [aws_lambda_permission.alb_invoke]
}

output "instance_tg_arn" {
  value = aws_lb_target_group.instance_tg.arn
}

output "lambda_tg_arn" {
  value = aws_lb_target_group.lambda_tg.arn
}
