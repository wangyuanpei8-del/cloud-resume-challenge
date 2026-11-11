# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "wangyuanpei-2026"
resource "aws_s3_bucket_public_access_block" "site" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = "wangyuanpei-2026"
  ignore_public_acls      = true
  region                  = "ap-southeast-2"
  restrict_public_buckets = true
  skip_destroy            = null
}

# __generated__ by Terraform from "wangyuanpei-2026"
resource "aws_s3_bucket_policy" "site" {
  bucket = "wangyuanpei-2026"
  policy = jsonencode({
    Id = "PolicyForCloudFrontPrivateContent"
    Statement = [{
      Action = "s3:GetObject"
      Condition = {
        ArnLike = {
          "AWS:SourceArn" = "arn:aws:cloudfront::331384580338:distribution/EM4EI1GT4BJCD"
        }
      }
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Resource = "arn:aws:s3:::wangyuanpei-2026/*"
      Sid      = "AllowCloudFrontServicePrincipal"
    }]
    Version = "2008-10-17"
  })
  region = "ap-southeast-2"
}

# __generated__ by Terraform from "E34X1OL7F8VVMV"
resource "aws_cloudfront_origin_access_control" "site" {
  description                       = "Created by CloudFront"
  name                              = "oac-wangyuanpei-2026.s3.ap-southeast-2.amazonaws.com-mw7nbtkmv0l"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# __generated__ by Terraform from "EM4EI1GT4BJCD"
resource "aws_cloudfront_distribution" "site" {
  aliases             = []
  anycast_ip_list_id  = null
  comment             = null
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
  tags_all = {
    Name = "WypResume"
  }
  wait_for_deployment = true
  web_acl_id          = null
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    field_level_encryption_id  = null
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = null
    realtime_log_config_arn    = null
    response_headers_policy_id = null
    smooth_streaming           = false
    target_origin_id           = "wangyuanpei-2026.s3.ap-southeast-2.amazonaws.com-mw7na7cmwae"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  origin {
    connection_attempts         = 3
    connection_timeout          = 10
    domain_name                 = "wangyuanpei-2026.s3.ap-southeast-2.amazonaws.com"
    origin_access_control_id    = "E34X1OL7F8VVMV"
    origin_id                   = "wangyuanpei-2026.s3.ap-southeast-2.amazonaws.com-mw7na7cmwae"
    origin_path                 = null
    response_completion_timeout = 0
  }
  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn            = null
    cloudfront_default_certificate = true
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = null
  }
}

# __generated__ by Terraform from "wangyuanpei-2026"
resource "aws_s3_bucket" "site" {
  bucket              = "wangyuanpei-2026"
  bucket_namespace    = "global"
  force_destroy       = false
  object_lock_enabled = false
  region              = "ap-southeast-2"
  tags                = {}
  tags_all            = {}
}
