# Versions épinglées : tout le monde (et la CI) utilise les mêmes outils.
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # toute version 6.x, jamais la 7 sans le décider
    }
  }
}
