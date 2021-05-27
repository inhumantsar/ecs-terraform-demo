output "ecs_exec_role_arn" {
  value = aws_iam_role.ecs_exec.arn
}

output "image" {
  value = local.image_url
}

output "artifact_bucket" {
  value = aws_s3_bucket.codepipeline.bucket
}