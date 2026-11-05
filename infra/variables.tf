# Les paramètres réglables de l'infrastructure.

variable "region" {
  description = "Région AWS où tout est créé"
  type        = string
  default     = "eu-north-1" # Stockholm : la région du projet Waxtan-Project
}

variable "projet" {
  description = "Nom du projet, utilisé dans les noms et les étiquettes"
  type        = string
  default     = "waxtan"
}

variable "environnement" {
  description = "Environnement déployé (prod, staging...)"
  type        = string
  default     = "prod"
}
