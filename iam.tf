# ECS instance role/policy
data "aws_iam_policy_document" "cluster_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster_instance" {
  name               = "${var.owner}-${var.environment}-ecs-cluster-instance"
  assume_role_policy = data.aws_iam_policy_document.cluster_instance.json
}


resource "aws_iam_role_policy_attachment" "cluster_instance" {
  role       = aws_iam_role.cluster_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "cluster_instance" {
  name = "${var.owner}-${var.environment}-ecs-cluster-instance"
  role = aws_iam_role.cluster_instance.name
}

resource "aws_iam_policy" "cluster_instance_ssm" {
  name        = "${var.owner}-${var.environment}-ecs-cluster-instance-ssm"
  description = "A policy to allow session manager"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetEncryptionConfiguration"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_instance_ssm" {
  role       = aws_iam_role.cluster_instance.name
  policy_arn = aws_iam_policy.cluster_instance_ssm.arn
}