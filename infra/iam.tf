# Lambda 専用の実行ロール（最小権限）
# import 時に、元のロール PowerUserRole に PowerUserAccess（ほぼ全サービスの操作権限）が
# 付いていることが分かったため、必要な権限だけを持つロールに置き換えた。

resource "aws_iam_role" "visitor_counter" {
  name        = "visitor-counter-role"
  description = "Execution role for the visitor-counter Lambda (least privilege)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# DynamoDB：対象テーブルの UpdateItem だけ（コードが使うのは update_item のみ）
resource "aws_iam_role_policy" "visitor_counter_dynamodb" {
  name = "visitor-count-update"
  role = aws_iam_role.visitor_counter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "dynamodb:UpdateItem"
      Resource = aws_dynamodb_table.visitor_count.arn
    }]
  })
}

# CloudWatch Logs：自分のロググループへの書き込みだけ
resource "aws_iam_role_policy" "visitor_counter_logs" {
  name = "visitor-counter-logs"
  role = aws_iam_role.visitor_counter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = [
        "arn:aws:logs:ap-southeast-2:331384580338:log-group:/aws/lambda/visitor-counter",
        "arn:aws:logs:ap-southeast-2:331384580338:log-group:/aws/lambda/visitor-counter:*",
      ]
    }]
  })
}

# 元のロール PowerUserRole は Terraform の管理から外すだけで、削除はしない
# （コンソールで作られた共用ロールの可能性があるため。不要と確認できたら手動で削除する）
removed {
  from = aws_iam_role.lambda_role
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role_policy.dynamodb_access
  lifecycle {
    destroy = false
  }
}
