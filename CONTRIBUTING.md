# Contribuer à Waxtan

Ce document décrit le parcours suivi pour toute modification du projet, de la création d'une branche jusqu'à la fusion dans `main`.

## Principes

- **`main` est protégée.** On ne pousse jamais directement dessus : tout passe par une pull request.
- **La CI doit être verte** (lint et build) avant toute fusion. GitHub bloque la fusion sinon.
- **Une PR = un changement cohérent = un commit** sur `main` (fusion en squash).
- **Aucun secret dans le dépôt.** Les clés vont dans `.env`, qui est ignoré par Git.

## Prérequis

- Node.js 24
- Git
- GitHub CLI (`gh`), authentifié avec `gh auth login`

Installation des dépendances après un clone :

```bash
npm ci
```

## Le parcours

### 1. Partir d'un `main` à jour

```bash
git switch main
git pull
```

### 2. Créer une branche

```bash
git switch -c type/description-courte
```

| Type | Usage |
|---|---|
| `feat/` | Nouvelle fonctionnalité visible par l'utilisateur |
| `fix/` | Correction de bug |
| `chore/` | Outillage, dépendances, configuration |
| `ci/` | Intégration continue (`.github/workflows/`) |
| `docs/` | Documentation |

Exemples : `feat/upload-cv`, `fix/micro-safari`, `chore/dockerfile`.

### 3. Développer et regarder le résultat

```bash
npm run dev
```

Puis ouvrir http://localhost:3000. Arrêter avec `Ctrl+C`.

### 4. Vérifier en local, comme la CI

```bash
npm run lint
npm run build
```

Aucune erreur ne doit apparaître. Si une commande échoue, on corrige avant d'aller plus loin.

### 5. Relire ce qui va être commité

```bash
git status
```

Vérifier qu'aucun fichier inattendu n'apparaît, en particulier aucun `.env`.

### 6. Commiter

```bash
git add -A
git commit -m "type: description"
```

Les messages suivent [Conventional Commits](https://www.conventionalcommits.org/fr/) : le préfixe reprend le type de la branche (`feat:`, `fix:`, `chore:`, `ci:`, `docs:`).

### 7. Pousser la branche

```bash
git push -u origin type/description-courte
```

### 8. Ouvrir la pull request

```bash
gh pr create --base main --title "type: description" --body "Ce qui change et pourquoi."
```

### 9. Suivre la CI

```bash
gh pr checks --watch
```

### 10. Fusionner, une fois la CI verte

```bash
gh pr merge --squash --delete-branch
```

### 11. Revenir sur `main` à jour

```bash
git switch main
git pull
```

## Aide-mémoire

```
git switch main → git pull → git switch -c type/nom
… coder …
npm run lint → npm run build → git status
git add -A → git commit -m "type: message"
git push -u origin type/nom
gh pr create → gh pr checks --watch → gh pr merge --squash --delete-branch
git switch main → git pull
```
