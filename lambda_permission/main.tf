# Grant ALB permission to invoke the Lambda function
# This is the step the AWS console handles automatically
# but that Terraform requires you to declare explicitly
resource "aws_lambda_permission" "alb_invoke" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = var.alb_arn
}
