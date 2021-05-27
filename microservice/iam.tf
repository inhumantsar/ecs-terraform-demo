# ecs has "execution" and "task" roles. the former is for the ECS environment, the latter is for
# the containers themselves. since secrets are used when *launching* the container, not in the
# container itself, this role will be an execution role.
resource "aws_iam_role" "ecs_exec" {
  name = "${var.name}_ecs_exec"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# attach the managed core exec role policy
resource "aws_iam_role_policy_attachment" "ecs_exec_basic" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# policies define what resources the users of a role should be given access to
resource "aws_iam_policy" "ecs_exec_secrets" {
  name = "${var.name}_ecs_exec"

  # as an alternative to jsonencode, we can use a Terraform data source to create complex objects
  policy = data.aws_iam_policy_document.ecs_exec_secrets.json
}

# the policy document data source defining which secrets this backend has access to
data "aws_iam_policy_document" "ecs_exec_secrets" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    # using a data source like this enables `for` expressions which should be familiar to any python user
    resources = [for n in var.secret_names : "arn:aws:secretsmanager:${var.region}::secret:${n}"]
  }
}

# attachment objects tie policies to the role
resource "aws_iam_role_policy_attachment" "ecs_exec_secrets" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = aws_iam_policy.ecs_exec_secrets.arn
}