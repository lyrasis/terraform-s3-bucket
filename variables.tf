# Input variable definitions

variable "name" {
  description = "Name of the s3 bucket. Must be unique."
  type        = string
}


variable "expiration_days" {
  description = "Number of days before objects in the bucket are to be deleted."
  type        = number
  default     = 30
}

variable "region" {
  default = "us-west-2"
}

variable "vpc_id" {
  description = "The ID of the VPC to which the bucket should be attached."
  type        = string
}

variable "route_table_id" {
  description = "The ID of the routing table with which the bucket should be associated."
  type        = string
}

variable "tags" {
  description = "Tags to set on the bucket."
  type        = map(string)
  default     = {}
}
