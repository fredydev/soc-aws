data "aws_iam_account_alias" "current" {}

locals {
  env       = "dev"
  project   = "connexion-soc"
  name      = join("-", [local.project, local.env])
  tags      = {
    Name    = local.name
    Owner   = "cagip_cyb_squad_native@ca-gip.fr"
    Entity  = "CA-GIP"
    Product = local.project
  }
}


# Regle Eventbridge
resource "aws_cloudwatch_event_rule" "aws_soc_push_rule" {
  name        = "securityhub-to-azuresentinel-${local.env}"
  description = "Get Security Hub finding and invoke api destination"

  event_pattern = <<EOF
{
  "source": ["aws.securityhub"],
  "detail-type": ["Security Hub Findings - Imported"]
}
EOF
}



resource "aws_cloudwatch_event_target" "aws_to_soc_rule_target" {
  target_id = "IngestSentinel"
  rule      = aws_cloudwatch_event_rule.aws_soc_push_rule.name
  arn       = aws_lambda_function.aws_to_soc.arn


}

# permission for eventbridge to invoke a lambda function
resource "aws_lambda_permission" "invoke_lambda_function" {
   statement_id  = "AllowEventBridgeInvokeLambda"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.aws_to_soc.function_name
   principal     = "events.amazonaws.com"
   source_arn = aws_cloudwatch_event_rule.aws_soc_push_rule.arn
}


# Lamda function
data "archive_file" "aws_to_soc" {
  type        = "zip"
  source_file = "${path.module}/functions/lambda_function.py"
  output_path = "${path.module}/functions/lambda_function.zip"
}

resource "aws_lambda_function" "aws_to_soc" {
  filename                       = data.archive_file.aws_to_soc.output_path
  function_name                  = join("-", ["aws-to-soc-findings", local.name,])
  handler                        = "lambda_function.lambda_handler"
  role                           = aws_iam_role.role_for_lambda.arn
  description                    = join(" ", ["securityhub-findings", local.name])
  runtime                        = "python3.6"
  timeout                        =  30
  source_code_hash               = data.archive_file.aws_to_soc.output_base64sha256
  tags                           = merge(local.tags, {Name = join("-", [local.name, "security-findings"])})
  environment {
    variables = {
      AZURE_WORKSPACE_ID         = var.azure_workspace_id
      AZURE_WORKSPACE_KEY        = var.azure_workspace_key
      AZURE_WORKSPACE_LOG_TYPE   = var.azure_workspace_logtype
    }
  }
}


resource "aws_cloudwatch_log_group" "aws_to_soc" {
  name              = "/aws/lambda/${aws_lambda_function.aws_to_soc.function_name}"
  retention_in_days = 3
  tags              = merge(local.tags, {Name = join("-", [local.name, "loggroup"])})
}

# Iam permissions for lambda
resource "aws_iam_role" "role_for_lambda" {
  name               = join("-",["securityhub-findings", local.name])
  assume_role_policy =  <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
tags = local.tags
}


resource "aws_iam_policy" "aws_to_soc_lambda" {
  name        = join("-", ["securityhub-lambda",local.name])
  path        = "/"
  description = "policy for lambda with basic execrole and listing organization permission"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "permission0",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "${split("log-group", "${aws_cloudwatch_log_group.aws_to_soc.arn}")[0]}*"
        },
        {
            "Sid": "permission1",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "${aws_cloudwatch_log_group.aws_to_soc.arn}"
        },
        {
            "Sid": "permission2",
            "Effect": "Allow",
            "Action": "organizations:ListParents",
            "Resource": "*"
        }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "attach_policy" {
  name       = "policy-attachment-to-lambda-role"
  roles      = [aws_iam_role.role_for_lambda.name]
  policy_arn = aws_iam_policy.aws_to_soc_lambda.arn
}