# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnets
resource "aws_subnet" "my_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.my_subnet_1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.my_subnet_2.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create an S3 Bucket for logs
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "my-ecs-logs-bucket-12345678" # Change to a unique bucket name
}

# Create an ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

# Create IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions    = jsonencode([{
    name      = "my-container"
    image     = "<your-docker-image>" # Replace with your Docker image URI from ECR or Docker Hub
    memory    = 512
    cpu       = 256
    essential = true

    logConfiguration = {
      logDriver = "json-file"
      options   = {
        max-size   = "10m"
        max-file   = "3"
      }
    }
    
    environment = [
      {
        name  = "LOG_BUCKET"
        value = aws_s3_bucket.logs_bucket.bucket // Pass the S3 bucket name as an environment variable if needed
      }
    ]
    
    portMappings = [{
      containerPort     = 80 # Change to your application's port
      hostPort          = 80 # Change to your application's port if necessary
      protocol          = "tcp"
    }]
  }])
}

# Create ECS Service
resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.id
  desired_count   = 1

  launch_type     = "EC2"

  network_configuration {
    subnets          = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true 
  }
}

# Create Security Group for ECS Service
resource "aws_security_group" "ecs_security_group" {
  vpc_id     = aws_vpc.my_vpc.id

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
