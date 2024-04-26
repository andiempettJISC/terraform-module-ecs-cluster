# Terraform Module ECS Cluster

A module to abstract the complexity of an ECS cluster that uses both instance and fargate capabilities

# Using The Terraform module

See [examples](./examples)

    module "cluster" {
        source = "github.com/example/terraform-module-ecs-cluster?ref=0.1.0"

        ...
        ...
    }


## Example Setup and deploy

[ECS cluster working example](./examples/cluster) is a working example.

then run the following:

    cd examples/cluster
    export AWS_REGION=eu-west-1
    terraform init

Then plan...

    terraform plan

...If the plan is successful apply.

    terraform apply

When you are finished destroy the resources

    terraform destroy

check the terraform state

    terraform state list
