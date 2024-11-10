terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


############ Creating a cloudformation stack ############
#resource "aws_cloudformation_stack" "ecsstack" {
#  name          = "ecs-stack"
# template_body = file("ECS_template.json")
#}