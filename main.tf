locals {
  resource_identifier = lower(var.resource_identifier) == "none" ? "${var.project}-${var.environment}" : var.resource_identifier
}

resource "aws_wafregional_ipset" "this" {
  count = var.module_enabled ? 1 : 0
  name  = "${local.resource_identifier} Allowed IPs"

  dynamic "ip_set_descriptor" {
    for_each = var.whitelist
    content {
      type  = ip_set_descriptor.value.type
      value = ip_set_descriptor.value.value
    }
  }
}

resource "aws_wafregional_rule" "this" {
  count       = var.module_enabled ? 1 : 0
  name        = "${local.resource_identifier}-WhitelistRule"
  metric_name = "${replace(local.resource_identifier, "/[^A-z]/", "")}WAFRule"

  predicate {
    type    = "IPMatch"
    data_id = aws_wafregional_ipset.this[0].id
    negated = false
  }
}

resource "aws_wafregional_regex_match_set" "healthcheck" {
  count = var.module_enabled ? 1 : 0
  name  = "${replace(local.resource_identifier, "/[^A-z]/", "")}-healthcheck"
  regex_match_tuple {
    field_to_match {
      type = "URI"
    }
    regex_pattern_set_id = aws_wafregional_regex_pattern_set.healthcheck[0].id
    text_transformation  = "NONE"
  }
}

resource "aws_wafregional_regex_pattern_set" "healthcheck" {
  count                 = var.module_enabled ? 1 : 0
  name                  = "${replace(local.resource_identifier, "/[^A-z]/", "")}-healthcheck"
  regex_pattern_strings = ["^/ping$", "^/healthcheck$", "^/checkout-api/check-current-live-region$", "^/web-api/check-current-live-region$"]
}

resource "aws_wafregional_rule" "healthcheck_rule" {
  count       = var.module_enabled ? 1 : 0
  name        = "${replace(local.resource_identifier, "/[^A-z]/", "")}healthcheck"
  metric_name = "${replace(local.resource_identifier, "/[^A-z]/", "")}healthcheck"

  predicate {
    type    = "RegexMatch"
    data_id = aws_wafregional_regex_match_set.healthcheck[0].id
    negated = false
  }
}

resource "aws_wafregional_web_acl" "this" {
  count       = var.module_enabled ? 1 : 0
  name        = local.resource_identifier
  metric_name = "${replace(local.resource_identifier, "/[^A-z]/", "")}WebACL"

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.this[0].id
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 2
    rule_id  = aws_wafregional_rule.healthcheck_rule[0].id
  }
}

resource "aws_wafregional_web_acl_association" "this" {
  count        = var.module_enabled ? 1 : 0
  resource_arn = var.load_balancer_arn
  web_acl_id   = aws_wafregional_web_acl.this[0].id
}
