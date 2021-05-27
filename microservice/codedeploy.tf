resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = var.name
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  //  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce" // defaults to TimeBasedCanary
  deployment_group_name  = var.name
  service_role_arn       = aws_iam_role.codedeploy.arn
  depends_on             = [aws_iam_role.codedeploy.arn]

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 10
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 10
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.this.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.prod_listener.arn]
      }

      test_traffic_route {
        listener_arns = [aws_lb_listener.test_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.tg1.name
      }

      target_group {
        name = aws_lb_target_group.tg2.name
      }

    }
  }
}


resource "aws_iam_role" "codedeploy" {
  name = "${var.name}-codedeploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# attaching a managed policy to the codedeploy role
resource "aws_iam_role_policy_attachment" "codedeploy_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy.name
}


# CodeDeploy permissions
# combination of https://docs.aws.amazon.com/AmazonECS/latest/developerguide/codedeploy_IAM_role.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
# and additional permissions to enable lambda-based custom CodeDeploy hooks for Jenkins integration
resource "aws_iam_role_policy" "codedeploy" {
  name = "${var.name}-codedeploy"
  role = aws_iam_role.codedeploy.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ecs:*",
              "elasticloadbalancing:*",
              "iam:PassRole",
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "s3:ListBucket",
              "s3:PutObject",
              "s3:GetObject",
              "lambda:ListFunctions",
              "lambda:ListTags",
              "lambda:GetEventSourceMapping",
              "lambda:ListEventSourceMappings",
              "lambda:InvokeFunction"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

