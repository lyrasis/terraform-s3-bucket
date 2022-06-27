# Input variable definitions

variable "name" {
  description = "Name of the s3 bucket. Must be unique."
  type        = string
}


variable "expiration_days" {
  description = "Number of days before objects in the bucket are to be deleted."
  type        = number
  default     = 0
}

variable "region" {
  default = "us-west-2"
}

variable "vpc_id" {
  description = "The ID of the VPC to which the bucket should be attached."
  type        = string
}

variable "tags" {
  description = "Tags to set on the bucket."
  type        = map(string)
  default     = {}
}

variable "read_only" {
  description = "Whether the IAM user is limited to read_only access"
  type = bool
  default = true
}
