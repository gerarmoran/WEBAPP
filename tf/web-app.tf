# Reference the existing Secrets Manager secret by ARN
data "aws_secretsmanager_secret" "private_message_secret" {
  arn = "arn:aws:secretsmanager:us-east-1:567009811953:secret:private_message-tDQWvh"
}

# Create an ECS Cluster for Fargate
resource "aws_ecs_cluster" "my_cluster" {
  name = "cluster-webapp"
}

# Create IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRoleweb"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

# Create ECS Task Definition with Fargate launch type
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([{
    name      = "my-container"
    image     = "567009811953.dkr.ecr.us-east-1.amazonaws.com/webapp:latest" # Replace with your Docker image URI from ECR or Docker Hub
    memory    = 512
    cpu       = 256
    essential = true

    environment = [
      {
        name  = "LOG_BUCKET"
        value = aws_s3_bucket.logs_bucket.bucket // Pass the S3 bucket name as an environment variable if needed
      },
      {
        name  = "PRIVATE_MESSAGE_SECRET_ID"
        value = aws_secretsmanager_secret.private_message_secret.id // Pass the secret ID as an environment variable to access it in the application
      }
    ]

    portMappings = [{
      containerPort = 80 # Change to your application's port
      hostPort      = 80 # Change to your application's port if necessary
      protocol      = "tcp"
    }]
  }])
}

############ Creating a cloudformation stack ############
resource "aws_cloudformation_stack" "ecsstack" {
  name          = "ecs-stack"
  template_body = file("ECS_template.json")


# Create Security Group for ECS Service
resource "aws_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80 # Change to your application's port if necessary
    to_port     = 80 # Change to your application's port if necessary
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}