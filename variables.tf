variable "alb_name" {
  description = "Name of the existing Application Load Balancer"
  type        = string
}

variable "ec2_instance_name" {
  description = "Name tag of the existing EC2 instance"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the existing Lambda function"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the resources are deployed"
  type        = string
}

variable "lambda_path" {
  description = "URL path to route to Lambda (e.g. /lambda)"
  type        = string
  default     = "/lambda"
}
