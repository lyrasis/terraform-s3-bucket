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

variable "tags" {
  description = "Tags to set on the bucket."
  type        = map(string)
  default     = {}
}
