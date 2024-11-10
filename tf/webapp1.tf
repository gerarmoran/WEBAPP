# Create an ECS Cluster for Fargate
resource "aws_ecs_cluster" "my_cluster" {
  name = "fargate-cluster"
}

############ Creating a cloudformation stack ############
resource "aws_cloudformation_stack" "ecsstack" {
  name          = "webapp-ecs"
  template_body = file("webapp.json")
}

