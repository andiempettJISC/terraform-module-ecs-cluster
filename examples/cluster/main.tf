# Add Terraform resources and modules here

locals {
  owner              = "example"
  app                = "shared"
  env                = terraform.workspace
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.owner}-${local.app}-${local.env}"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

}

# Create an ECS cluster that supports both fargate and instance tasks. Uses mixed instance types and supports cloudmap.
module "ecs_cluster" {
  source          = "../../."
  instance_type   = "t3.small"
  vpc_id          = local.vpc_id
  private_subnets = local.private_subnet_ids
  environment     = local.env
  owner           = local.owner
  additional_instances = [
    "t2.medium",
    "t3.medium"
  ]
  instance_min_size = 3
  instance_max_size = 5
  enable_cloudmap   = true
}

# Create an ECS cluster that supports both fargate and instance tasks. supports ARM64 instance architecture and supports cloudmap.
# module "ecs_cluster_arm" {
#   source          = "../../."
#   instance_type   = "t4g.small"
#   vpc_id          = local.vpc_id
#   private_subnets = local.private_subnet_ids
#   environment     = local.env
#   owner           = local.owner
#   instance_min_size = 3
#   instance_max_size = 5
#   enable_cloudmap = true
#   architecture = "ARM"
# }

# Create an ECS cluster only uses fargate to run tasks. No instances are ran because instance sizes are 0.
# module "ecs_cluster_fargate" {
#   source          = "../../."
#   vpc_id          = local.vpc_id
#   private_subnets = local.private_subnet_ids
#   environment     = local.env
#   owner           = local.owner
#   enable_cloudmap   = true
# }