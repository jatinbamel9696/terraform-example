resource "aws_route53_resolver_rule" "fwd" {
  name                 = replace(var.forward_domain, ".", "-")
  domain_name          = var.forward_domain
  resolver_endpoint_id = var.resolver_endpoint
  rule_type            = "FORWARD"
  tags                 = var.tags

  dynamic "target_ip" {
    for_each = var.forward_ips

    content {
      ip   = target_ip.value
      port = var.dns_port
    }
  }
}

resource "aws_route53_resolver_rule_association" "fwdrule" {
  count            = var.associated_vpcs != null ? length(var.associated_vpcs) : 0
  resolver_rule_id = aws_route53_resolver_rule.fwd.id
  vpc_id           = var.associated_vpcs[count.index]
  
  depends_on = [aws_route53_resolver_rule.fwd]
}