# Terraform Module: S3 Bucket

This is a Terraform module that can be used to create an S3 bucket, along with
an IAM user with access to it.

## Usage Example

```terraform
locals {  
  default_tags = {
    Department  = DTS
    Environment = prod
    Service     = Islandora
  }
  name_prefix = "is-prod"
  buckets     = ["clienta", "clientb"]
  expiration_days = 5 # optional. default 30 days
}

module "s3_bucket" {
  source    = "./modules/s3_bucket"
  for_each  = local.buckets
  name      = "${local.name_prefix}-${each.key}-bucket"
  tags      = local.default_tags
}
```
