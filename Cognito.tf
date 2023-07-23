//Create a Cognito user pool
resource "aws_cognito_user_pool" "pool" {
  name                     = "WEBAPP_COGNITO_EXAMPLE"
  auto_verified_attributes = ["email"]
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }

  alias_attributes = [
    "email",
  ]

  username_configuration {
    case_sensitive = false
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true # false for "sub"
    required                 = true # true for "sub"
    string_attribute_constraints {  # if it is a string
      min_length = 0                # 10 for "birthdate"
      max_length = 2048             # 10 for "birthdate"
    }
  }

  password_policy {
    require_numbers                  = false
    minimum_length                   = 6
    require_symbols                  = false
    require_uppercase                = false
    require_lowercase                = false
    temporary_password_validity_days = 7
  }


  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }


  #   verification_message_template {
  #     default_email_option = "CONFIRM_WITH_CODE"
  #     email_message        = "Your verification code is {####}."
  #     email_subject        = "Verify your email address for our App"
  #   }

  lambda_config {
    post_confirmation = aws_lambda_function.post_confirmation.arn
  }
}


// Create App Client
resource "aws_cognito_user_pool_client" "client" {
  name                                 = "client"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  generate_secret                      = false
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  callback_urls                        = ["https://google.com"]
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["phone", "email", "openid"]
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers         = ["COGNITO"]
}


// Cognito domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.domain
  user_pool_id = aws_cognito_user_pool.pool.id

}

// Hosted UI

resource "aws_cognito_user_pool_ui_customization" "example" {
  client_id = aws_cognito_user_pool_client.client.id

  css        = ".label-customizable {font-weight: 400;}"
  image_file = filebase64("ZDF_logo!_Logo_2021.svg.png")

  # Refer to the aws_cognito_user_pool_domain resource's
  # user_pool_id attribute to ensure it is in an 'Active' state
  user_pool_id = aws_cognito_user_pool_domain.main.user_pool_id
}



