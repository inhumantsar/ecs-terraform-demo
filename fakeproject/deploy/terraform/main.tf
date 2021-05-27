module "microservice" {
  source = "../../../microservice"

  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids = var.public_subnet_ids
  task_definition = var.task_def_path
  vpc_id = var.vpc_id
  log_level = var.log_level
  region = var.region
  environment = var.environment
  port = var.port
}