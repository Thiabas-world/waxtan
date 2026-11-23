# ECR : le registre privé des images Docker de Waxtan.
# La CI y enverra l'image à chaque fusion, le serveur EC2 la téléchargera.

resource "aws_ecr_repository" "app" {
  name = var.projet # le dépôt s'appellera "waxtan"

  # Tags immuables : une étiquette (le hash du commit) désigne UNE image pour
  # toujours. Personne ne peut écraser "a1b2c3d" avec une autre image.
  image_tag_mutability = "IMMUTABLE"

  # Analyse de sécurité basique à chaque envoi (gratuite) : AWS cherche les
  # vulnérabilités connues (CVE) dans les paquets de l'image.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Chiffrement au repos avec une clé gérée par AWS (gratuit).
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.projet}-ecr"
  }
}

# Le ménage automatique : sans lui, chaque fusion ajoute une image
# et la facture de stockage grossit sans fin.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Supprimer les images sans étiquette après 1 jour"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Garder seulement les 10 images les plus récentes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
