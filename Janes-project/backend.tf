# store the terraform state file in s3
terraform {
  backend "s3" {
    bucket    = "janes-tatiana-test-project-10101"
    key       = "terraform.tfstate"
    region    = "eu-west-2"
    dynamodb_table = "janes_project_statefile_locking_table"
    profile   = "default"
  }
}