resource "aws_dynamodb_table" "cognito_users-table" {
  name           = "cognito_users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Email"

  attribute {
    name = "Email"
    type = "S"
  }
}
