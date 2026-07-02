resource "aws_wafv2_web_acl" "main" {
  name        = "rate-limit-web-acl"
  description = "Web ACL that rate limits specific IPs with a CAPTCHA challenge"
  scope       = "REGIONAL"


  default_action {
    allow {}
  }

  rule {
    name     = "IPRateLimitWithCaptcha"
    priority = 1 

   
    action {
      captcha {}
    }

    statement {
      rate_based_statement {
        limit              = 800 
        aggregate_key_type = "IP"
      }
    }

   
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPRateLimitWithCaptchaMetric"
      sampled_requests_enabled   = true
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MainWebACLMetric"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = var.alb-arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn  
}