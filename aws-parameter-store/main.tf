resource "aws_ssm_parameter" "foo" {
  for_each = var.key_value_pairs
  type     = "String"
  name     = each.key
  value    = each.value
}