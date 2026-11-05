# Le provider AWS : il traduit le code en appels à l'API d'AWS.
# Aucune clé ici : il réutilise la session ouverte par "aws login".
provider "aws" {
  region = var.region

  # Étiquettes posées automatiquement sur TOUTES les ressources :
  # on sait ce qui appartient à Waxtan, qui l'a créé, et on suit les coûts.
  default_tags {
    tags = {
      Projet        = var.projet
      Environnement = var.environnement
      GerePar       = "terraform"
      Depot         = "github.com/Thiabas-world/waxtan"
    }
  }
}
