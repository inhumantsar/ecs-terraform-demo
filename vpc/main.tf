data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

# this official community-supported module rolls up a number of vpc-related resources
# into a single, simpler interface loaded with sane defaults
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name

  cidr = "10.0.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic

  azs              = ["ca-central-1a", "ca-central-1b", "ca-central-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  # elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
  # redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]
  # intra subnets are for systems which have *no* internet traffic in or out.
  # intra_subnets       = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]

  create_database_subnet_group = true

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  # VPC Endpoints allow AWS API traffic for a particular service to avoid hitting the internet at all.
  # Without them, API traffic originating from ECS and targeting (eg) ECR would have to route out via
  # the VPC's internet gateway. 
  #
  # Cost: $0.01/hr/az/endpoint + $0.01/GB

  # VPC Endpoint for ECR API
  # enable_ecr_api_endpoint              = true
  # ecr_api_endpoint_policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
  # ecr_api_endpoint_private_dns_enabled = true
  # ecr_api_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC Endpoint for ECR DKR
  # enable_ecr_dkr_endpoint              = true
  # ecr_dkr_endpoint_policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
  # ecr_dkr_endpoint_private_dns_enabled = true
  # ecr_dkr_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC endpoint for KMS
  # enable_kms_endpoint              = true
  # kms_endpoint_private_dns_enabled = true
  # kms_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC endpoint for ECS
  # Not required when using Fargate, but endpoints for ECR, CodeDeploy, etc. are still required
  # enable_ecs_endpoint              = true
  # ecs_endpoint_private_dns_enabled = true
  # ecs_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC endpoint for ECS telemetry
  # enable_ecs_telemetry_endpoint              = true
  # ecs_telemetry_endpoint_private_dns_enabled = true
  # ecs_telemetry_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC endpoint for CodeDeploy
  # enable_codedeploy_endpoint              = true
  # codedeploy_endpoint_private_dns_enabled = true
  # codedeploy_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC endpoint for CodeDeploy Commands Secure
  # enable_codedeploy_commands_secure_endpoint              = true
  # codedeploy_commands_secure_endpoint_private_dns_enabled = true
  # codedeploy_commands_secure_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  # tags = {
  #   Owner       = "user"
  #   Environment = "staging"
  #   Name        = "complete"
  # }

  # vpc_endpoint_tags = {
  #   Project  = "Secret"
  #   Endpoint = "true"
  # }
}
