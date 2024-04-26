resource "aws_service_discovery_private_dns_namespace" "cluster" {
  count       = var.enable_cloudmap ? 1 : 0
  name        = "${var.owner}.${var.environment}.cluster"
  description = "ECS cluster ${var.owner}.${var.environment}"
  vpc         = var.vpc_id
}