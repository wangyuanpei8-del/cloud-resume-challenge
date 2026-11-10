# アクセス数を保存するテーブル（項目は id = "visitors" の 1 件だけ）
resource "aws_dynamodb_table" "visitor_count" {
  name         = "visitor-count"
  billing_mode = "PAY_PER_REQUEST" # オンデマンド課金。アクセスが少ないので固定費なし
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
