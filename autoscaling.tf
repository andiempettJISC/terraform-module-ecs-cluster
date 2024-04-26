resource "aws_autoscaling_policy" "container_instance_cpu_reservation" {
  name                   = "${var.owner}-${var.environment}-CPUReservation"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
  # adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = aws_ecs_cluster.cluster.name
      }

      metric_name = "CPUUtilization"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }

    target_value = "80.0"
  }
}

resource "aws_autoscaling_policy" "container_instance_memory_reservation" {
  name                   = "${var.owner}-${var.environment}-MemoryReservation"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
  # adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = aws_ecs_cluster.cluster.name
      }

      metric_name = "MemoryUtilization"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }

    target_value = "80.0"
  }
}