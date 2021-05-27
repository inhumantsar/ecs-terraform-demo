# Define common tags to be used for all (supported) resources
locals {
  appmesh_virtual_service_name = "${var.name}.${var.service_namespace}.${var.service_tld}"
  image_url = "${aws_ecr_repository.this.repository_url}:${var.environment}"

  common_tags = {
    BuiltWith = "terraform"
  }

  default_tags = merge(
    local.common_tags,
    map(
      "Name", "${var.name}",
      "Environment", "${var.environment}"
    )
  )
}

data "aws_caller_identity" "current" {}
