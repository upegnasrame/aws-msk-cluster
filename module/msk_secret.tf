

locals {
  secret_string       = var.enabled ? {
    for user in range(0, length(var.msk_user_list)) : user =>
    {
      username        = var.msk_user_list[user].username,
      password        = random_password.randomised_pwd[user].result
    }
  } : {}
}
resource "random_password" "randomised_pwd" {
  count               = var.enabled ? length(var.msk_user_list) : 0
  length              = 16
  special             = true
  override_special    = "_%@"
}


resource "aws_secretsmanager_secret" "msk_secret" {
  count               = var.enabled ? length(var.msk_user_list) : 0
  name                = "AmazonMSK_user/app/${var.application_name}/${var.environment}/${var.mask_user_list[count.index].username}"
  kms_key_id          = data.aws_kms_alias
}

resource "null_resource" "put_secret_value" {
  for_each            = var.enabled ? local.secret_string : {}
  triggers            = {
    secret_id         = aws_secretsmanager_secret.msk_secret[each.key].id
  }
  provisioner "local-exec" {
    command           = "aws secretsmanager put-secret-value --secret-id ${aws_secretsmanager_secret.msk_secret[each.key].id} --secret-string $(echo $INIT_PW |base64 -d) --region ${data.aws_region.current.name}"
    environment       = {
      INIT_PW         = base64encode(jsonencode(each.value))
    }
  }
}

resource "aws_msk_scram_secret_association" "this" {
  count               = var.enabled ? 1 : 0
  cluster_arn         = aws_msk_cluster.this.0.arn
  secret_arn_list     = aws_secretsmanager_secret.msk_secret.*.arn
  depends_on          = [null_resource.put_secret_value]
}

// to-do secrets rotation

