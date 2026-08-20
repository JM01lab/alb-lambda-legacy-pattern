data "aws_lb" "existing_alb" {
  name = var.alb_name
}

data "aws_instance" "legacy_app" {
  filter {
    name   = "tag:Name"
    values = [var.ec2_instance_name]
  }
}

data "aws_lambda_function" "new_feature" {
  function_name = var.lambda_function_name
}

module "target_groups" {
  source              = "./modules/target_groups"
  vpc_id              = var.vpc_id
  ec2_instance_id     = data.aws_instance.legacy_app.id
  lambda_function_arn = data.aws_lambda_function.new_feature.arn
}

module "listener" {
  source                    = "./modules/listener"
  alb_arn                   = data.aws_lb.existing_alb.arn
  instance_target_group_arn = module.target_groups.instance_tg_arn
  lambda_target_group_arn   = module.target_groups.lambda_tg_arn
  lambda_path               = var.lambda_path
}

module "lambda_permission" {
  source              = "./modules/lambda_permission"
  lambda_function_arn = data.aws_lambda_function.new_feature.arn
  alb_arn             = data.aws_lb.existing_alb.arn
}
