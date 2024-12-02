resource "aws_ssm_parameter" "foo" {
  count = length(var.key_value_pairs)
  type  = "String"
  name  = var.key_value_pairs[0].key
  value = var.key_value_pairs[0].value
}