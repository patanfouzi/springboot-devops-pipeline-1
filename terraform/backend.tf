terraform {
  backend "s3" {
    bucket = "REPLACE_WITH_YOUR_S3_BUCKET"
    key    = "secure-devops-pipeline-minimal/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
