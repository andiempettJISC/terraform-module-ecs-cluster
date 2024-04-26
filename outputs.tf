output "id" {
  value = aws_ecs_cluster.cluster.id
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.ecs.name
}

output "cloudmap_namespace_id" {
  value = var.enable_cloudmap ? aws_service_discovery_private_dns_namespace.cluster[0].id : null
}

output "cloudmap_namespace_name" {
  value = var.enable_cloudmap ? aws_service_discovery_private_dns_namespace.cluster[0].name : null
}