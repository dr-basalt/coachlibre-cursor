# Utiliser l'image Node.js officielle
FROM node:18-alpine AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier tout le workspace pour avoir accès aux packages
COPY . .

# Installer pnpm
RUN npm install -g pnpm

# Installer toutes les dépendances du workspace
RUN pnpm install

# Construire les packages du workspace dans l'ordre correct
RUN pnpm run build --filter=@coachlibre/shared
RUN pnpm run build --filter=@coachlibre/ui

# Build de l'application frontend
RUN pnpm run build --filter=@coachlibre/frontend

# Stage de production
FROM node:18-alpine AS runner

WORKDIR /app

# Installer pnpm
RUN npm install -g pnpm

# Copier les fichiers de production
COPY --from=builder /app/apps/frontend/dist ./dist
COPY --from=builder /app/apps/frontend/package*.json ./

# Installer uniquement les dépendances de production
RUN pnpm install --prod --filter=@coachlibre/frontend

# Exposer le port
EXPOSE 3000

# Variable d'environnement
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Commande de démarrage
CMD ["pnpm", "preview", "--host", "0.0.0.0", "--port", "3000"] 