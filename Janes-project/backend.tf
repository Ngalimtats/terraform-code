# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "janes-project-test101"
    key       = "terraform.tfstate"
    region    = "us-east-1"
    #dynamodb_table = "janes_project_statefile_locking_table"
    profile   = "default"
  }
}