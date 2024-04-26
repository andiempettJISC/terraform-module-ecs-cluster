locals {
  ami_id = var.ami_id != null ? var.ami_id : (var.architecture == "STANDARD" ? data.aws_ssm_parameter.ecs_ami_amd64.value : data.aws_ssm_parameter.ecs_ami_arm64.value)
}