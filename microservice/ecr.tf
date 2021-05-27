resource "aws_ecr_repository" "this" {
  name = var.name
}

resource "aws_iam_policy" "ecr_push" {
  name = "${var.name}_ecr_push"
  policy = data.aws_iam_policy_document.ecr_push.json
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    actions = [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ]
    resources = [aws_ecr_repository.this.arn]
  }
}