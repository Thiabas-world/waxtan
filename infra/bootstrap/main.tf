# Bootstrap : crée le bucket S3 qui stockera l'état Terraform de infra/.
#
# Le problème de la poule et l'œuf : le bucket de l'état doit exister AVANT
# que infra/ s'en serve. Ce petit dossier séparé le crée, avec un état local.
# On ne le relance presque jamais : une fois au début, c'est tout.
#
# Usage (dans infra/bootstrap) : terraform init, puis terraform apply.

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Projet        = "waxtan"
      Environnement = "prod"
      GerePar       = "terraform"
      Depot         = "github.com/Thiabas-world/waxtan"
    }
  }
}

# Le bucket de l'état. Son nom doit être unique AU MONDE (tous comptes AWS
# confondus) : d'où le suffixe aléatoire, tiré une fois pour toutes.
resource "aws_s3_bucket" "etat" {
  bucket = "waxtan-tfstate-6e5bb32f"

  # Il contient l'état de TOUTE l'infrastructure : Terraform refusera de le
  # détruire. Pour le supprimer un jour, il faudra retirer cette ligne exprès.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "waxtan-tfstate"
  }
}

# Versionnement : chaque version de l'état est gardée.
# Si l'état est abîmé, on revient à la version précédente.
resource "aws_s3_bucket_versioning" "etat" {
  bucket = aws_s3_bucket.etat.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrement au repos, avec une clé gérée par S3 (gratuit).
resource "aws_s3_bucket_server_side_encryption_configuration" "etat" {
  bucket = aws_s3_bucket.etat.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Blocage de tout accès public : le bucket ne pourra jamais devenir public,
# même par une erreur de politique plus tard.
resource "aws_s3_bucket_public_access_block" "etat" {
  bucket = aws_s3_bucket.etat.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Le ménage des vieilles versions : on garde 90 jours d'historique,
# sinon les versions s'accumulent sans fin (et coûtent, même peu).
resource "aws_s3_bucket_lifecycle_configuration" "etat" {
  bucket = aws_s3_bucket.etat.id

  rule {
    id     = "anciennes-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  # Le versionnement doit être actif avant de régler ses expirations.
  depends_on = [aws_s3_bucket_versioning.etat]
}

output "bucket_etat" {
  description = "Nom du bucket qui stocke l'état Terraform"
  value       = aws_s3_bucket.etat.bucket
}
