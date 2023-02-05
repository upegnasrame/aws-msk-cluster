

# create msk cluster
variable "enabled" {
  default = ""
}
variable "cluster_name" {
  default = ""
}
variable "kafka_version" {
  default = ""
}
variable "number_of_nodes" {
  default = ""
}
variable "enhanced_monitoring" {
  default = ""
}
variable "client_subnets" {
  default = ""
}

variable "firehose_logs_delivery_stream" {
  default = ""
}
variable "cloudwatch_logs_group" {
  default = ""
}
variable "s3_logs_bucket" {
  default = ""
}
variable "s3_logs_prefix" {
  default = ""
}

variable "instance_type" {
  default = ""
}
variable "ebs_volume_size" {
  default = ""
}
variable "provisioned_volume_throughput" {
  default = ""
}

variable "is_custom_prop_enabled" {
  default = ""
}
variable "server_properties" {
  default = ""
}

variable "msk_user_list" {
  default = ""
}

variable "mask_user_list" {
  default = ""
}
variable "environment" {
  default = ""
}
variable "application_name" {
  default = ""
}

//noinspection ConflictingProperties
variable "is_nat_enabled" {
  default = ""
}