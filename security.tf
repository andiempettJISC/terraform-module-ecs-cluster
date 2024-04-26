resource "aws_security_group" "cluster_internal" {
  name        = "${var.owner}-${var.environment}-cluster-internal"
  description = "Allow internal http access from ALBs"
  vpc_id      = var.vpc_id

  # Fargate maps target group ports to container ports. 
  # ECS will dynamically assign ports to tasks on an instance in the target group
  # https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PortMapping.html
  dynamic "ingress" {
    for_each = var.instance_allow_security_group_ids != [] ? var.instance_allow_security_group_ids : []
    content {
      description     = "Allow internal access from the api ALB to the tasks"
      from_port       = 49153
      to_port         = 65535
      protocol        = "tcp"
      security_groups = var.instance_allow_security_group_ids
    }
  }

  egress {
    description      = "Allow all egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.owner}-${var.environment}-cluster-internal"
  }
}