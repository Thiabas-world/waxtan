# syntax=docker/dockerfile:1

# Image Docker de Waxtan, construite en plusieurs étapes (multi-stage build) :
# les outils de build restent dans les étapes intermédiaires, seule l'étape
# finale "runner" part en production.

# — Base commune : Node 24 sur Alpine Linux (image légère) —
FROM node:24-alpine AS base
ENV NEXT_TELEMETRY_DISABLED=1

# — Étape 1 : installer les dépendances —
# On copie d'abord uniquement package.json et le lock file : tant qu'ils ne
# changent pas, Docker réutilise cette étape depuis son cache.
FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json ./
# Cache npm partagé entre les builds (--mount=type=cache) : un paquet déjà
# téléchargé n'est pas retéléchargé, même après un échec. Délais et
# tentatives augmentés pour les connexions lentes.
RUN --mount=type=cache,target=/root/.npm \
    npm ci --fetch-retries=5 --fetch-retry-mintimeout=20000 --fetch-retry-maxtimeout=120000 --fetch-timeout=600000

# — Étape 2 : construire l'application —
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# — Étape 3 : l'image finale, qui tourne en production —
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME=0.0.0.0

# Utilisateur sans privilèges : l'app ne tourne pas en root
RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 nextjs

# Serveur standalone + fichiers statiques (CSS, JS, polices).
# Quand le dossier public/ existera, ajouter :
# COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
