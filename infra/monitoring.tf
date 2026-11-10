# 監視・通知：エラーが起きたら SNS 経由でメールを送る
# 通知先のメールアドレスは公開リポジトリに載せないため、サブスクリプションはコンソールで手動登録する
resource "aws_sns_topic" "alerts" {
  name = "resume-site-alerts"
}

# Lambda がエラーを 1 回でも返したら通知
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "resume-site-lambda-errors"
  alarm_description   = "visitor-counter の Lambda でエラーが発生"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = aws_lambda_function.visitor_counter.function_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching" # アクセスがない時間は「正常」とみなす
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

# API Gateway が 5xx（サーバー側のエラー）を返したら通知
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name        = "resume-site-api-5xx"
  alarm_description = "visitor-api が 5xx エラーを返した"
  namespace         = "AWS/ApiGateway"
  metric_name       = "5xx"
  dimensions = {
    ApiId = aws_apigatewayv2_api.visitor_api.id
    Stage = aws_apigatewayv2_stage.default.name
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}
