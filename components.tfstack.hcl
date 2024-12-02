# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

component "s3" {
  for_each = var.regions

  source = "./s3"

  inputs = {
    region = each.value
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }
}

component "lambda" {
  for_each = var.regions

  source = "./lambda"

  inputs = {
    region    = var.regions
    bucket_id = component.s3[each.value].bucket_id
  }

  providers = {
    aws     = provider.aws.configurations[each.value]
    archive = provider.archive.this
    local   = provider.local.this
    random  = provider.random.this
  }
}

component "api_gateway" {
  for_each = var.regions

  source = "./api-gateway"

  inputs = {
    region               = each.value
    lambda_function_name = component.lambda[each.value].function_name
    lambda_invoke_arn    = component.lambda[each.value].invoke_arn
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }
}

component "parameter-store" {
  for_each = var.regions

  source = "./aws-parameter-store"

  inputs = {
    key_value_pairs = { "s3_bucket_arn_${each.value}" : component.s3[each.value].bucket_arn }
  }

  providers = {
    aws = provider.aws.configurations[each.value]
  }
}

component "cluster" {
  for_each = var.regions
  source   = "./cluster"

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }

  inputs = {
    cluster_name       = var.cluster_name
    kubernetes_version = var.kubernetes_version
    region             = each.value
  }
}

component "kube" {
  for_each = var.regions
  source   = "./kube"

  providers = {
    kubernetes = provider.kubernetes.main[each.value]
  }
}
