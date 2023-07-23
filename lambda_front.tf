resource "aws_iam_role" "front_lambda_role" {
  name = "front_lambda_role"

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


resource "aws_iam_policy" "policy_front_lambda" {
  name = "policy_front_lambda"
  path = "/"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : "arn:aws:logs:*:757158648679:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:CreateLogGroup"
          ],
          "Resource" : "arn:aws:logs:*:757158648679:*:*:*"
        },
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ssm:PutParameter",
            "ssm:DeleteParameter",
            "ssm:GetParameterHistory",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:DeleteParameters"
          ],
          "Resource" : "arn:aws:ssm:*:757158648679:parameter/*"
        }
      ]
    }
  )
}




// Attach the front policy to front iam role 
resource "aws_iam_role_policy_attachment" "policy_front_lambda_attach_to_role" {
  role       = aws_iam_role.front_lambda_role.name
  policy_arn = aws_iam_policy.policy_front_lambda.arn
}

data "archive_file" "zip_front_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/front_app.zip"
}

resource "aws_lambda_function" "front_app_function" {
  filename      = "${path.module}/python/front_app.zip"
  function_name = "front_app_function"
  role          = aws_iam_role.front_lambda_role.arn
  handler       = "front_app.lambda_handler"
  runtime       = "python3.10"
  depends_on    = [aws_iam_role_policy_attachment.policy_front_lambda_attach_to_role]
}


