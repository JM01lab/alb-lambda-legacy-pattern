# Listener on port 80 — default traffic goes to EC2
resource "aws_lb_listener" "http" {
  load_balancer_arn = var.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.instance_target_group_arn
  }
}

# Listener Rule — specific path goes to Lambda
resource "aws_lb_listener_rule" "lambda_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10  # Lower number = higher priority

  condition {
    path_pattern {
      values = [var.lambda_path]
    }
  }

  action {
    type             = "forward"
    target_group_arn = var.lambda_target_group_arn
  }
}
