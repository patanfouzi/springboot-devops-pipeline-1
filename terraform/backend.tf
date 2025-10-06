terraform {
  backend "s3" {
    bucket = "my-slurm-state-bucket"
    key    = "secure-devops-pipeline-minimal/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
