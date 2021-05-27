// these are written out to tf.env which is then used to update task_def.json

output "name" {
  value = var.name
}

output "region" {
  value = var.region
}

output "image" {
  value = module.microservice.image
}

output "log_level" {
  value = var.log_level
}

output "ecs_exec_role_arn" {
  value = module.microservice.ecs_exec_role_arn
}

output "artifact_bucket" {
  value = module.microservice.artifact_bucket
}

output "port" {
  value = var.port
}