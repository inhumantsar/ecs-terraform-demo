resource "aws_ecs_cluster" "this" {
  name               = var.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

data "template_file" "task_definition" {
  template = var.task_definition

  vars = {
    region = var.region
    name = var.name
    image = local.image_url
    log_level = var.log_level
  }
}

resource "aws_ecs_task_definition" "initial_task_definition" {
  depends_on            = [aws_cloudwatch_log_group.service]
  family                = var.name
  container_definitions = data.template_file.task_definition.rendered
  task_role_arn         = aws_iam_role.ecs_exec.id
  network_mode          = "awsvpc"
  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      AppPorts         = "80"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      IgnoredUID       = "1337"
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

resource "aws_ecs_service" "this" {
  task_definition = aws_ecs_task_definition.initial_task_definition.arn

  name          = var.name
  cluster       = aws_ecs_cluster.this.id
  desired_count = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.tg1.arn
    container_name   = var.name
    container_port   = var.port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    // security_groups = [var.security_group_ids] // not sure this is necessary with fargate

  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  depends_on = [aws_lb_target_group.tg1]

  lifecycle {
    ignore_changes = [
      "task_definition",
      "desired_count",
      "load_balancer",
    ]
  }
}
