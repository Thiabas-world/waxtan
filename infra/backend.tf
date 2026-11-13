# L'état distant : l'état de infra/ est rangé dans S3, plus sur un PC.
# Le bucket est créé par infra/bootstrap (le problème de la poule et l'œuf).
#
# Attention : pas de variables possibles ici. Le backend est lu par
# "terraform init", AVANT que les variables existent.
terraform {
  backend "s3" {
    bucket       = "waxtan-tfstate-6e5bb32f"
    key          = "prod/terraform.tfstate" # le chemin du fichier dans le bucket
    region       = "eu-north-1"
    encrypt      = true # l'état est chiffré dans S3
    use_lockfile = true # le verrou : un fichier .tflock pendant chaque opération
  }
}
