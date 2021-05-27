variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "name" {
  type = string
  default = "myapp"
  description = "Used to name app-specific resources like the ECS cluster and App Mesh"
}

variable "internal" {
  type = bool
  default = false
  description = "Set to 'true' to hide the load balancer from the public internet"
}

variable "environment" {
  type = string
  description = "Service environment. eg: latest or stable"
  default = "latest"
}

variable "log_level" {
  type = string
  default = "debug"
}

variable "desired_count" {
  type = number
  default = 2
}

variable "port" {
  type = number
  default = 80
}

variable "task_definition" {
  type = string
  description = "Path to task definition template"
}

variable "test_port" {
  type = number
  default = 8000
  description = "Port for the test listener to use"
}

variable "health_check_path" {
  type = string
  default = status
  description = "Path of the target group health check back to the task"
}

variable "healthy_threshold" {
  type = number
  description = "Number of successful health checks required for a healthy service."
  default = 3
}

variable "unhealthy_threshold" {
  type = number
  description = "Number of failed health checks required for an unhealthy service."
  default = 3
}

variable "health_check_interval" {
  type = number
  description = "Time in seconds between health checks."
  default = 10
}

# the names provided here refer to secrets stored in AWS Secret Manager
# these secrets should already exist prior to running this
variable "secret_names" {
  type = list(string)
  default = []
}

# name + service namespace + service_tld == name other services in the mesh can use to look up this application.
variable "service_namespace" {
  type = string
  default = "svc"
  description = "Service discovery namespace shared throughout the service mesh. You probably don't want to change this."
}

# this one is funky, check the docs: https://docs.aws.amazon.com/app-mesh/latest/userguide/virtual_services.html
variable "service_tld" {
  type = string
  default = "cluster.local"
  description = "Used within the App Mesh to define virtual service names. You probably don't want to change this."
}

variable "region" {
  type = string
  default = "ca-central-1"
}

