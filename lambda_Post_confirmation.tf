resource "aws_iam_role" "post_confirmation" {
  name = "cognito-post-confirmation-lambda-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "user_data_to_db" {
  name = "user_data_to_db"
  path = "/"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "CognitoPermissions",
          "Effect" : "Allow",
          "Action" : [
            "cognito-idp:ListUsers",
            "cognito-idp:AdminGetUser",
            "cognito-idp:AdminDeleteUser",
            "cognito-idp:AdminCreateUser"
          ],
          "Resource" : "arn:aws:cognito-idp:*:757158648679:userpool/*"
        },
        {
          "Sid" : "DynamoDBPermissions",
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:PutItem",
            "dynamodb:GetItem",
            "dynamodb:UpdateItem"
          ],
          "Resource" : "arn:aws:dynamodb:*:757158648679:table/*"
        },
        {
          "Sid" : "SSMParameterPermissions",
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParameterHistory"
          ],
          "Resource" : "arn:aws:ssm:*:757158648679:parameter/*"

        },
        {
          "Sid" : "CloudWatchLogsFullAccess",
          "Effect" : "Allow",
          "Action" : [
            "logs:*"
          ],
          "Resource" : "*"

        },
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::cf-templates-9qfnmzt02w6g-us-east-1/*"
        }

      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "post_lambda_policy_attachment" {
  role       = aws_iam_role.post_confirmation.name
  policy_arn = aws_iam_policy.user_data_to_db.arn
}

data "archive_file" "zip_post_confirmation" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/post_confirmation.zip"
}

resource "aws_lambda_function" "post_confirmation" {
  filename      = "${path.module}/python/post_confirmation.zip"
  function_name = "post_confirmation"
  role          = aws_iam_role.post_confirmation.arn
  handler       = "post_confirmation.lambda_handler"
  runtime       = "python3.10"
  depends_on    = [aws_iam_role_policy_attachment.post_lambda_policy_attachment, aws_dynamodb_table.cognito_users-table]
}
