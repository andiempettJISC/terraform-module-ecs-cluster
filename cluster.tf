data "aws_default_tags" "current" {}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.owner}-${var.environment}"
}

resource "aws_ecs_cluster_capacity_providers" "ecs" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.ecs.name,
    "FARGATE",
    "FARGATE_SPOT"
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs.name
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  image_id = local.ami_id
  iam_instance_profile {
    name = aws_iam_instance_profile.cluster_instance.name
  }
  vpc_security_group_ids = [aws_security_group.cluster_internal.id]
  user_data = base64encode(templatefile("${path.module}/userdata.yml", {
    ECS_CLUSTER         = aws_ecs_cluster.cluster.name
    ECS_RESERVED_MEMORY = 128
    # Custom Attributes or 'taints' we can use as a selector for which instances a task may run
    ECS_INSTANCE_ATTRIBUTES = "{\"ecs_instance_type\": \"standard\"}"
  }))
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.owner}-${var.environment}-cluster"
  vpc_zone_identifier = var.private_subnets

  min_size                  = var.instance_min_size
  max_size                  = var.instance_max_size
  health_check_grace_period = 60
  health_check_type         = "EC2"
  protect_from_scale_in     = true

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs_launch_template.id
        version            = "$Latest"
      }
      dynamic "override" {
        for_each = var.additional_instances
        content {
          instance_type = override.value
        }
      }
    }
  }

  dynamic "tag" {
    for_each = data.aws_default_tags.current.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  tag {
    key                 = "Name"
    value               = "${var.owner}-${var.environment}-cluster"
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "ecs" {
  name = "${var.owner}-${var.environment}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 100
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

data "aws_ssm_parameter" "ecs_ami_amd64" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

data "aws_ssm_parameter" "ecs_ami_arm64" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended/image_id"
}