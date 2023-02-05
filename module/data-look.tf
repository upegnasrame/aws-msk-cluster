locals {
  server_properties = join("\n", [for k, v in var.server_properties : format("%s = %s", k, v)])
  enable_logs       = var.s3_logs_bucket != "" || var.cloudwatch_logs_group != "" || var.firehose_logs_delivery_stream != "" ? ["true"] : []
}

data "aws_subnet_ids" "tier2_subnets" {
  vpc_id      = data.aws_vpc.vpc.id

  filter {
    name      = "tag:Name"
    values    = "tier2"
  }
}

data "aws_subnet" "nat_subnets" {
  count       = var.is_nat_enabled ? 1 : 0

  filter {
    name      = "vpc-id"
    values    = [data.aws_vpc.vpc.id]
  }

  tags = {
    name      = "*nat*"
  }
}

data "aws_subnet" "tier2_subnet_ids" {
  count       = length(data.aws_subnet_ids.tier2_subnets.ids)
  id = length(var.client_subnets) != 0 ? element(tolist(data.aws_subnet_ids.tier2_subnets), count.index) : var.client_subnets[0]
}

data "aws_subnet" "nat_subnet_ids" {
  count       = var.is_nat_enabled ? length(data.aws_subnets.nat_subnets[0].ids) : 0
  id          = element(tolist(data.aws_subnet.nat_subnets[0].ids), count.index)
}

