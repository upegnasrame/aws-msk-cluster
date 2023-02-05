
resource "aws_msk_configuration" "this" {
  count             = var.enabled && var.is_custom_prop_enabled ? 1 : 0
  kafka_versions    = [var.kafka_version]
  name              = "${var.cluster_name}-config"
  server_properties = var.server_properties

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_msk_cluster" "this" {
  count                 = var.enabled > 0 ? 1 : 0
  depends_on = [aws_msk_configuration.this]

  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    client_subnets  = length(var.client_subnets) != 0 ? data.aws_subnet_ids.tier2_subnets.ids : var.client_subnets
    instance_type   = var.instance_type
    security_groups = [aws_security_group.this.*.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size

        provisioned_throughput {
          enabled           = var.provisioned_volume_throughput == null ? false : true
          volume_throughput = var.provisioned_volume_throughput
        }
      }
    }
  }

  dynamic "configuration_info" {
    for_each = aws_msk_configuration.this
    content {
      arn      = aws_msk_configuration.this.arn
      revision = aws_msk_configuration.this.latest_revision
    }
  }

  client_authentication {
    unauthenticated = var.client_authentication_unauthenticated_enabled
    sasl {
      iam   = var.client_authentication_sasl_iam_enabled
      scram = length(var.client_authentication_sasl_scram_secrets_arns) == 0 ? false : true
    }
    dynamic "tls" {
      for_each = length(var.client_authentication_tls_certificate_authority_arns) != 0 ? ["true"] : []
      content {
        certificate_authority_arns = var.client_authentication_tls_certificate_authority_arns
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  dynamic "logging_info" {
    for_each = local.enable_logs
    content {
      broker_logs {
        dynamic "firehose" {
          for_each = var.firehose_logs_delivery_stream != "" ? ["true"] : []
          content {
            enabled         = true
            delivery_stream = var.firehose_logs_delivery_stream
          }
        }
        dynamic "cloudwatch_logs" {
          for_each = var.cloudwatch_logs_group != "" ? ["true"] : []
          content {
            enabled   = true
            log_group = var.cloudwatch_logs_group
          }
        }
        dynamic "s3" {
          for_each = var.s3_logs_bucket != "" ? ["true"] : []
          content {
            enabled = true
            bucket  = var.s3_logs_bucket
            prefix  = var.s3_logs_prefix
          }
        }
      }
    }
  }

  tags = var.tags
}
