# サイトのファイルを置く S3 バケット（非公開）
# コンソールで作成済みのものを import した。中のファイルは GitHub Actions が同期する
resource "aws_s3_bucket" "site" {
  bucket              = "wangyuanpei-2026"
  bucket_namespace    = "global"
  force_destroy       = false
  object_lock_enabled = false
  region              = "ap-southeast-2"
  tags                = {}
}

# バケットへの公開アクセスをすべてブロック
resource "aws_s3_bucket_public_access_block" "site" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.site.id
  ignore_public_acls      = true
  region                  = "ap-southeast-2"
  restrict_public_buckets = true
}

# バケットポリシー：このサイトの CloudFront ディストリビューションからの読み取りだけを許可
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Id = "PolicyForCloudFrontPrivateContent"
    Statement = [{
      Action = "s3:GetObject"
      Condition = {
        ArnLike = {
          "AWS:SourceArn" = aws_cloudfront_distribution.site.arn
        }
      }
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Resource = "${aws_s3_bucket.site.arn}/*"
      Sid      = "AllowCloudFrontServicePrincipal"
    }]
    Version = "2008-10-17"
  })
  region = "ap-southeast-2"
}

# OAC：CloudFront が S3 へのリクエストに署名するための設定
resource "aws_cloudfront_origin_access_control" "site" {
  description                       = "Created by CloudFront"
  name                              = "oac-wangyuanpei-2026.s3.ap-southeast-2.amazonaws.com-mw7nbtkmv0l"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront ディストリビューション：HTTPS でサイトを配信する入口
# キャッシュポリシーは AWS 管理の CachingOptimized を使用
resource "aws_cloudfront_distribution" "site" {
  aliases             = []
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  staging             = false
  tags = {
    Name = "WypResume"
  }
  wait_for_deployment = true
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "wangyuanpei-2026.s3.ap-southeast-2.amazonaws.com-mw7na7cmwae"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  origin {
    connection_attempts         = 3
    connection_timeout          = 10
    domain_name                 = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id    = aws_cloudfront_origin_access_control.site.id
    origin_id                   = "wangyuanpei-2026.s3.ap-southeast-2.amazonaws.com-mw7na7cmwae"
    response_completion_timeout = 0
  }
  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
