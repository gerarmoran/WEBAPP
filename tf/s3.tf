# Create an S3 Bucket for logs (optional)
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "my-ecs-logs-bucket-83781" # Change to a unique bucket name
}
