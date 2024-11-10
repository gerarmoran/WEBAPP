
# Create an AWS Secrets Manager secret for the private message
resource "aws_secretsmanager_secret" "private_message_secret" {
  name        = "message_private"
  description = "Stores the private message for the application."
}

resource "aws_secretsmanager_secret_version" "private_message_version" {
  secret_id     = aws_secretsmanager_secret.private_message_secret.id
  secret_string = file("C:/WEB-APP/secret.json")
}
