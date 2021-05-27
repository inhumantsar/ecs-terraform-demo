variable "name" {
  type = string
  description = "App name"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "task_def_path" {
  type = string
  description = "Path to a task definition file that has had its jinja variables replaced"
}

variable "region" {
  type = string
  default = "ca-central-1"
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

variable "port" {
  type = number
  default = 80
}

