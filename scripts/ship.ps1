<#
.SYNOPSIS
  Livre une modification de Waxtan : branche, vérifications, commit, push,
  pull request et fusion automatique quand la CI est verte.

.DESCRIPTION
  À lancer depuis main, avec des modifications pas encore commitées.
  Le script pose 3 questions (type, nom de branche, message) puis enchaîne
  tout le parcours décrit dans CONTRIBUTING.md. Il s'arrête à la première
  erreur, sans rien pousser.

.EXAMPLE
  ./scripts/ship.ps1
#>

$ErrorActionPreference = "Stop"

$typesValides = @("feat", "fix", "chore", "ci", "docs")

function Etape($texte) { Write-Host "`n==> $texte" -ForegroundColor Cyan }
function Echec($texte) { Write-Host "`nERREUR : $texte" -ForegroundColor Red; exit 1 }

# Lance une commande externe et s'arrête si elle échoue (code de sortie non nul).
function Executer($commande, [string[]]$arguments) {
  & $commande @arguments
  if ($LASTEXITCODE -ne 0) { Echec "'$commande $($arguments -join ' ')' a échoué." }
}

# gh n'est pas toujours dans le PATH sur Windows : on le cherche aussi à son emplacement d'installation.
$gh = (Get-Command gh -ErrorAction SilentlyContinue).Source
if (-not $gh) { $gh = "C:\Program Files\GitHub CLI\gh.exe" }
if (-not (Test-Path $gh)) { Echec "GitHub CLI (gh) introuvable." }

# --- 1. Vérifications de départ ---------------------------------------------

Etape "Vérification de l'état du dépôt"

$branche = git branch --show-current
if ($branche -ne "main") { Echec "Lance le script depuis main (branche actuelle : $branche)." }

git fetch --quiet origin
if ((git rev-parse main) -ne (git rev-parse origin/main)) {
  Echec "main n'est pas à jour avec GitHub. Lance 'git pull' puis relance le script."
}

$changements = git status --porcelain
if (-not $changements) { Echec "Aucune modification à livrer." }

# Garde-fou : aucun fichier .env ne doit partir sur GitHub.
if ($changements | Where-Object { $_ -match "\.env" }) {
  Echec "Un fichier .env apparaît dans les modifications. Vérifie le .gitignore."
}

Write-Host "Modifications qui seront livrées :"
git status --short

# --- 2. Les questions -------------------------------------------------------

Etape "Description de la modification"

do {
  $type = (Read-Host "Type ($($typesValides -join ', '))").Trim().ToLower()
} until ($typesValides -contains $type)

do {
  $nom = (Read-Host "Nom court de la branche, en minuscules et tirets (ex: upload-cv)").Trim()
} until ($nom -match "^[a-z0-9]+(-[a-z0-9]+)*$")

do {
  $description = (Read-Host "Message du commit (sans le type)").Trim()
} until ($description)

$brancheCible = "$type/$nom"
$message = "${type}: $description"

Write-Host "`nBranche : $brancheCible"
Write-Host "Commit  : $message"
$confirmation = Read-Host "On livre ? (o/n)"
if ($confirmation -ne "o") { Write-Host "Annulé, rien n'a été modifié."; exit 0 }

# --- 3. Branche et vérifications locales (shift left) -----------------------

Etape "Création de la branche $brancheCible"
Executer git @("switch", "-c", $brancheCible)

Etape "Lint"
Executer npm @("run", "lint")

Etape "Build"
Executer npm @("run", "build")

# --- 4. Commit, push, pull request ------------------------------------------

Etape "Commit"
Executer git @("add", "-A")
Executer git @("commit", "-m", $message)

Etape "Push"
Executer git @("push", "-u", "origin", $brancheCible)

Etape "Ouverture de la pull request"
Executer $gh @("pr", "create", "--base", "main", "--title", $message, "--body", $description)

Etape "Activation de la fusion automatique"
# La PR sera fusionnée (squash) dès que la CI sera verte. GitHub supprime
# ensuite la branche distante (réglage "delete_branch_on_merge" du dépôt).
Executer $gh @("pr", "merge", "--auto", "--squash")

Write-Host "`nC'est livré. La PR sera fusionnée automatiquement si la CI passe." -ForegroundColor Green
Write-Host "Pour suivre la CI : gh pr checks --watch"
Write-Host "Une fois fusionnée : git switch main ; git pull ; git branch -d $brancheCible ; git fetch --prune"
