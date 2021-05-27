# NOTE we have to manually create the CloudWatch event to trigger the ECR source stage in the pipeline due to:
# https://github.com/terraform-providers/terraform-provider-aws/issues/7012

data "template_file" "ecr_event" {
  template = file("${path.module}/templates/ecr-source-event.json")

  vars = {
    ecr_name  = aws_ecr_repository.this.name
    image_tag = var.environment
  }
}

resource "aws_cloudwatch_event_rule" "ecr_rule" {
  name          = var.name
  description   = "Starts pipeline for ${var.name} when ECR image is updated."
  event_pattern = data.template_file.ecr_event.rendered

  depends_on = ["aws_codepipeline.pipeline"]
}

resource "aws_cloudwatch_event_target" "codepipeline_target" {
  rule      = aws_cloudwatch_event_rule.ecr_rule.name
  target_id = var.name
  arn       = aws_codepipeline.pipeline.arn
  role_arn  = aws_iam_role.cloudwatch_event.arn
}

resource "aws_iam_role" "cloudwatch_event" {
  name = "${var.name}_cloudwatch_event"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_event" {
  name = "${var.name}_cloudwatch_event"
  role = "${aws_iam_role.cloudwatch_event.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Resource": [
        "${aws_codepipeline.pipeline.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${var.name}"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "service_envoy" {
  name              = "/ecs/${var.name}-envoy"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "service_xray" {
  name              = "/ecs/${var.name}-xray"
  retention_in_days = 90
}

resource "aws_iam_role_policy" "task_role_policies" {
  name   = "${var.name}_task_role_policies"
  role   = aws_iam_role.ecs_exec.id
  policy = data.aws_iam_policy_document.task_role_policies.json
}

data "aws_iam_policy_document" "task_role_policies" {
  statement {
    sid = "LogToCloudWatch"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}
