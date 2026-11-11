# ダッシュボード：サイトの状態を 1 画面で確認する
# 上段にアラームの状態、中段に API Gateway、下段に Lambda と DynamoDB を並べる
locals {
  dashboard_region = "ap-southeast-2"

  api_dimensions = [
    "ApiId", aws_apigatewayv2_api.visitor_api.id,
    "Stage", aws_apigatewayv2_stage.default.name,
  ]
  lambda_dimensions = ["FunctionName", aws_lambda_function.visitor_counter.function_name]
  table_dimensions  = ["TableName", aws_dynamodb_table.visitor_count.name]
}

resource "aws_cloudwatch_dashboard" "site" {
  dashboard_name = "resume-site"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "alarm"
        x      = 0
        y      = 0
        width  = 24
        height = 3
        properties = {
          title = "アラームの状態"
          alarms = [
            aws_cloudwatch_metric_alarm.lambda_errors.arn,
            aws_cloudwatch_metric_alarm.api_5xx.arn,
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 8
        height = 6
        properties = {
          title   = "API：リクエスト数"
          region  = local.dashboard_region
          view    = "timeSeries"
          stat    = "Sum"
          period  = 300
          metrics = [concat(["AWS/ApiGateway", "Count"], local.api_dimensions)]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 3
        width  = 8
        height = 6
        properties = {
          title  = "API：エラー数（4xx・5xx）"
          region = local.dashboard_region
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          metrics = [
            concat(["AWS/ApiGateway", "4xx"], local.api_dimensions),
            concat(["AWS/ApiGateway", "5xx"], local.api_dimensions),
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 3
        width  = 8
        height = 6
        properties = {
          title  = "API：応答時間（ミリ秒）"
          region = local.dashboard_region
          view   = "timeSeries"
          period = 300
          metrics = [
            concat(["AWS/ApiGateway", "Latency"], local.api_dimensions, [{ stat = "Average", label = "平均" }]),
            concat(["AWS/ApiGateway", "Latency"], local.api_dimensions, [{ stat = "Maximum", label = "最大" }]),
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 9
        width  = 8
        height = 6
        properties = {
          title  = "Lambda：実行回数とエラー数"
          region = local.dashboard_region
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          metrics = [
            concat(["AWS/Lambda", "Invocations"], local.lambda_dimensions),
            concat(["AWS/Lambda", "Errors"], local.lambda_dimensions),
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 9
        width  = 8
        height = 6
        properties = {
          title  = "Lambda：実行時間（ミリ秒）"
          region = local.dashboard_region
          view   = "timeSeries"
          period = 300
          metrics = [
            concat(["AWS/Lambda", "Duration"], local.lambda_dimensions, [{ stat = "Average", label = "平均" }]),
            concat(["AWS/Lambda", "Duration"], local.lambda_dimensions, [{ stat = "Maximum", label = "最大" }]),
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 9
        width  = 8
        height = 6
        properties = {
          title  = "DynamoDB：書き込み量とスロットル"
          region = local.dashboard_region
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          metrics = [
            concat(["AWS/DynamoDB", "ConsumedWriteCapacityUnits"], local.table_dimensions),
            concat(["AWS/DynamoDB", "WriteThrottleEvents"], local.table_dimensions),
          ]
        }
      },
    ]
  })
}
