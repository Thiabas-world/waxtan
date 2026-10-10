#!/usr/bin/env bash
#
# ship.sh : livre une modification de Waxtan.
#
# Depuis main (modifications pas encore commitées) :
#   crée la branche, lance lint et build, commite, pousse, ouvre la pull
#   request et active la fusion automatique (dès que la CI est verte).
#
# Depuis une branche de travail (après un échec, par exemple réseau) :
#   reprend là où le script s'était arrêté, sans refaire ce qui est déjà fait.
#
# Usage : ./scripts/ship.sh   (dans Git Bash sous Windows)

set -euo pipefail

TYPES="feat fix chore ci docs"

etape() { printf '\n\033[36m==> %s\033[0m\n' "$1"; }
echec() { printf '\n\033[31mERREUR : %s\033[0m\n' "$1" >&2; exit 1; }

# Relance une commande réseau jusqu'à 4 fois, avec une pause qui double à
# chaque échec (5 s, 10 s, 20 s) : c'est le backoff exponentiel.
reessayer() {
  local tentative=1 max=4 pause=5
  until "$@"; do
    if (( tentative >= max )); then
      echec "'$*' a échoué après $max tentatives."
    fi
    # Sur la sortie d'erreur (>&2) : ce message ne doit pas se mélanger au
    # résultat de la commande quand on le capture avec $(...).
    printf '\033[33mÉchec (tentative %d/%d), nouvel essai dans %d s...\033[0m\n' "$tentative" "$max" "$pause" >&2
    sleep "$pause"
    tentative=$((tentative + 1))
    pause=$((pause * 2))
  done
}

# gh n'est pas toujours dans le PATH sous Windows.
if command -v gh >/dev/null 2>&1; then
  GH="gh"
elif [[ -x "/c/Program Files/GitHub CLI/gh.exe" ]]; then
  GH="/c/Program Files/GitHub CLI/gh.exe"
else
  echec "GitHub CLI (gh) introuvable."
fi

verifier_secrets() {
  if git status --porcelain | grep -Eq '(^|/)\.env'; then
    echec "Un fichier .env apparaît dans les modifications. Vérifie le .gitignore."
  fi
}

verifications_locales() {
  etape "Lint"
  npm run lint
  etape "Build"
  npm run build
}

demander_message() {
  local description=""
  while [[ -z "$description" ]]; do
    read -rp "Message du commit (sans le type) : " description
  done
  MESSAGE="$1: $description"
}

branche=$(git branch --show-current)

if [[ "$branche" == "main" ]]; then
  # --- Nouvelle livraison ----------------------------------------------------

  etape "Vérification de l'état du dépôt"
  reessayer git fetch --quiet origin
  if [[ "$(git rev-parse main)" != "$(git rev-parse origin/main)" ]]; then
    echec "main n'est pas à jour avec GitHub. Lance 'git pull' puis relance le script."
  fi
  if [[ -z "$(git status --porcelain)" ]]; then
    echec "Aucune modification à livrer."
  fi
  verifier_secrets

  echo "Modifications qui seront livrées :"
  git status --short

  etape "Description de la modification"
  type=""
  until [[ " $TYPES " == *" $type "* && -n "$type" ]]; do
    read -rp "Type ($TYPES) : " type
  done
  nom=""
  until [[ "$nom" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; do
    read -rp "Nom court de la branche, en minuscules et tirets (ex: upload-cv) : " nom
  done
  demander_message "$type"
  branche="$type/$nom"

  printf '\nBranche : %s\nCommit  : %s\n' "$branche" "$MESSAGE"
  read -rp "On livre ? (o/n) : " confirmation
  [[ "$confirmation" == "o" ]] || { echo "Annulé, rien n'a été modifié."; exit 0; }

  etape "Création de la branche $branche"
  git switch -c "$branche"
  verifications_locales

  etape "Commit"
  git add -A
  git commit -m "$MESSAGE"
else
  # --- Reprise sur une branche existante ------------------------------------

  etape "Reprise de la livraison sur $branche"
  type="${branche%%/*}"
  [[ " $TYPES " == *" $type "* ]] || echec "Branche '$branche' : le préfixe doit être l'un de : $TYPES."

  if [[ -n "$(git status --porcelain)" ]]; then
    # Le script s'était arrêté avant le commit (lint ou build en échec, par exemple).
    verifier_secrets
    git status --short
    verifications_locales
    demander_message "$type"
    etape "Commit"
    git add -A
    git commit -m "$MESSAGE"
  fi

  reessayer git fetch --quiet origin
  if [[ -z "$(git log origin/main..HEAD --oneline)" ]]; then
    echec "La branche ne contient aucun commit par rapport à main : rien à livrer."
  fi
fi

# --- Livraison : chaque étape peut être relancée sans risque (idempotente) ---

etape "Push"
reessayer git push -u origin "$branche"

etape "Pull request"
pr=$(reessayer "$GH" pr list --head "$branche" --state open --json number --jq '.[0].number // empty')
if [[ -n "$pr" ]]; then
  echo "La pull request #$pr existe déjà, on la réutilise."
else
  titre=$(git log -1 --format=%s)
  reessayer "$GH" pr create --base main --title "$titre" --body "$titre"
fi

etape "Activation de la fusion automatique"
reessayer "$GH" pr merge "$branche" --auto --squash

printf '\n\033[32mC'"'"'est livré. La PR sera fusionnée automatiquement si la CI passe.\033[0m\n'
echo "Suivre la CI      : gh pr checks --watch"
echo "Une fois fusionnée : git switch main && git pull && git branch -d $branche && git fetch --prune"
