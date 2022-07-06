terraform {
  backend "s3" {
    bucket      = "jenkins-gogreen"
    key         = "NewRepo/tfstate.tf"
    region      = "us-east-1"
    encrypt     = true
  }
}