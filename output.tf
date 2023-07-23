# output "user_pool_id" {
#   value = aws_cognito_user_pool.pool.id
# }
# output "endpoint_url" {
#   value = "${aws_api_gateway_stage.stage.invoke_url}/${var.endpoint}"
# }
# output "ui_url" {
#   value = "https://${var.domain}/login?response_type=token&client_id=${aws_cognito_user_pool_client.client.id}&redirect_uri=${aws_api_gateway_stage.stage.invoke_url}/${var.endpoint}"
# }
