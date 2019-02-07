locals {
  resource_identifier = "${ lower(var.resource_identifier) == "none" ? "${var.project}-${var.environment}" : var.resource_identifier }"
}

resource "aws_wafregional_ipset" "this" {
  count = "${ var.module_enabled ? 1 : 0 }"
  name  = "${local.resource_identifier} Allowed IPs"

  ip_set_descriptor = ["${var.whitelist}"]
}

resource "aws_wafregional_rule" "this" {
  count       = "${ var.module_enabled ? 1 : 0 }"
  name        = "${local.resource_identifier}-WhitelistRule"
  metric_name = "${replace(local.resource_identifier, "/[^A-z]/", "")}WAFRule"

  predicate {
    type    = "IPMatch"
    data_id = "${aws_wafregional_ipset.this.0.id}"
    negated = false
  }
}

resource "aws_wafregional_web_acl" "this" {
  count       = "${ var.module_enabled ? 1 : 0 }"
  name        = "${local.resource_identifier}"
  metric_name = "${replace(local.resource_identifier, "/[^A-z]/", "")}WebACL"

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_wafregional_rule.this.0.id}"
  }
}

resource "aws_wafregional_web_acl_association" "this" {
  count        = "${ var.module_enabled ? 1 : 0 }"
  resource_arn = "${var.load_balancer_arn}"
  web_acl_id   = "${aws_wafregional_web_acl.this.0.id}"
}
