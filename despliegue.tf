# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Create a route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt.id
}

# Create an ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "my-cluster"
}

# Create a Secrets Manager secret to store the message
resource "aws_secretsmanager_secret" "message" {
  name        = "message"
  description = "Message for home page"
}

resource "aws_secretsmanager_secret_version" "message_version" {
  secret_id = aws_secretsmanager_secret.message.id
  secret_string = jsonencode({
    message = "Buenos días, Ecuador"
  })
}

############ Creating a cloudformation stack ############
resource "aws_cloudformation_stack" "ecsstack" {
  name          = "webapp-ecs"
  template_body = file("webapp.json")
}

# Security Group to allow traffic
resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
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

output "vpc_id" {
  value = aws_vpc.main.id
}

output "secret_arn" {
  value = aws_secretsmanager_secret.message.arn
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}
