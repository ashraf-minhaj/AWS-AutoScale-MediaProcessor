locals {
  s3_origin_id = "test_s3_origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {

}

resource "aws_cloudfront_distribution" "destination_distribution" {
  origin {
    domain_name                   = aws_s3_bucket.destination_bucket.bucket_regional_domain_name
    # origin_access_control_id   = aws_cloudfront_origin_access_control.default.id
    origin_id                     = local.s3_origin_id
  }

  enabled                         = true
  is_ipv6_enabled                 = true

  default_cache_behavior {
    # allowed_methods         = ["HEAD", "GET", "OPTIONS", "PATCH", "POST", "PUT"]
    allowed_methods               = ["HEAD", "GET"]
    cached_methods                = ["HEAD", "GET"]
    target_origin_id              = local.s3_origin_id

    forwarded_values {
      query_string                = false
      cookies {
        forward                   = "none"
      }
    }

    viewer_protocol_policy        = "redirect-to-https"
    min_ttl                       = 0
    default_ttl                   = 3600
    max_ttl                       = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type              = "none"
      }
  }

  price_class                       = "PriceClass_All"

  viewer_certificate {
    cloudfront_default_certificate  = true
  }
    
  tags = {
    description                     = "test-min"
  }


  # # Cache behavior with precedence 0
  # ordered_cache_behavior {
  #     # path_pattern     = "/content/immutable/*"
  #     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #     cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #     target_origin_id = local.s3_origin_id

  #     forwarded_values {
  #     query_string = false
  #     headers      = ["Origin"]

  #     cookies {
  #         forward = "none"
  #         }
  #     }

  #     min_ttl                = 0
  #     default_ttl            = 86400
  #     max_ttl                = 31536000
  #     compress               = true
  #     viewer_protocol_policy = "redirect-to-https"
  # }
}