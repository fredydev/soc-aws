# Regle Eventbridge
resource "aws_cloudwatch_event_rule" "aws_soc_push_rule" {
  name        = "securityhub-to-azuresentinel-${var.environment}"
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
  source_arn    = aws_cloudwatch_event_rule.aws_soc_push_rule.arn
}



resource "aws_lambda_function" "aws_to_soc" {
  filename         = data.archive_file.aws_to_soc.output_path
  function_name    = "aws-to-soc-findings-${local.name}"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.role_for_lambda.arn
  description      = join(" ", ["securityhub-findings", local.name])
  runtime          = "python3.6"
  timeout          = 30
  source_code_hash = data.archive_file.aws_to_soc.output_base64sha256
  tags             = merge(local.tags, { Name = "security-findings-${local.name}" })
  environment {
    variables = {
      AZURE_WORKSPACE_ID       = var.azure_workspace_id
      AZURE_WORKSPACE_KEY      = var.azure_workspace_key
      AZURE_WORKSPACE_LOG_TYPE = var.azure_workspace_logtype
    }
  }
}


resource "aws_cloudwatch_log_group" "aws_to_soc" {
  name              = "/aws/lambda/${aws_lambda_function.aws_to_soc.function_name}"
  retention_in_days = 3
  tags              = merge(local.tags, { Name = "loggroup-${local.name}" })
}

