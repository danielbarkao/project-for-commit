resource "aws_ssm_parameter" "cognito_userpool" {
  name        = "userpool_id" # Change this to the desired parameter name and path.
  description = "User pool ID stored in SSM Parameter Store"
  type        = "String"
  value       = aws_cognito_user_pool.pool.id # Set the value you want to store here.
}
resource "aws_ssm_parameter" "dynamodb_table_name" {
  name        = "dynamodb_table_name" # Change this to the desired parameter name and path.
  description = "DynamoDB Table Name Stored in SSM Parameter Store"
  type        = "String"
  value       = aws_dynamodb_table.cognito_users-table.name # Set the value you want to store here.
}

