
resource "aws_security_group" "this" {
  count       = var.enabled ? 1 : 0
  name_prefix = "${var.cluster_name}-"
  vpc_id      = data.aws_subnet.this.vpc_id
}

resource "aws_security_group_rule" "msk-tls" {
  count             = var.enabled ? 1 : 0
  from_port         = 9094
  to_port           = 9094
  protocol          = "tcp"
  security_group_id = aws_security_group.this.0.id
  type              = "ingress"
  cidr_blocks       = split (
    ",",
    var.is_nat_enabled ? join (
      ",",
      concat (
        data.aws_subnet.nat_subnet_ids.*.cidr_block,
        data.aws_subnet.tier2_subnet_ids.*.cidr_block,
      ),
    ) : join(",", data.aws_subnet.tier2_subnet_ids.*.cidr_block),
  )
}

resource "aws_security_group_rule" "zookeeper-tls" {
  from_port         = 2182
  to_port           = 2182
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  cidr_blocks       = split (
    ",",
    var.is_nat_enabled ? join (
      ",",
      concat (
        data.aws_subnet.nat_subnet_ids.*.cidr_block,
        data.aws_subnet.tier2_subnet_ids.*.cidr_block,
      ),
    ) : join(",", data.aws_subnet.tier2_subnet_ids.*.cidr_block),
  )
}
