terraform {
  backend "s3" {
    bucket      = "terraform-backend-leyla"
    key         = "NewRepo/tfstate.tf"
    region      = "us-east-1"
    encrypt     = true
  }
}