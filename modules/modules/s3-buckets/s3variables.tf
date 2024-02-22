
variable "bucket_name" {
    type = string
    description = "Name of S3 bucket"
}

variable "env"{
    type = string
    description = "Bucket tag by purpose"
}

variable "versioning" {
    type = string
    default = "Disabled"
    description = "bucket versioning status"
}