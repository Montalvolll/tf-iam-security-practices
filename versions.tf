terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    # https://registry.terraform.io/providers/hashicorp/random/latest/docs
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }

    # http = {
    #   source = "hashicorp/http"
    # }
  }
}
