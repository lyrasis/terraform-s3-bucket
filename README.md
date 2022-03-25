# Terraform Module: S3 Bucket

This is a Terraform module that can be used to create an S3 bucket, along with
an IAM user with access to it.

## NOTE:
Version 1 of this module supports aws provider < 4
Version 2 requires aws provider version >= 4
see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade#s3-bucket-refactor

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
  region      = "us-west-2"
  expiration_days = 30 # optional. by default objects will not expire
}

module "s3_bucket" {
  source          = "./modules/s3_bucket"
  for_each        = local.buckets
  name            = "${local.name_prefix}-${each.key}-bucket"
  expiration_days = local.expiration_days
  region          = local.region
  vpc_id          = aws_vpc.default.id
  tags            = local.default_tags
}
```

Additionally, your containing terraform project will probably want to create an S3 VPC
endpoint. Something along these lines:

```terraform
resource "aws_vpc_endpoint" "s3" {
  vpc_id        = aws_vpc.default.id
  service_name  = "com.amazonaws.${var.region}.s3"

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-vpce-s3"
    },
  )
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
```
