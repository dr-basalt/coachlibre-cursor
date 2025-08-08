# Utiliser l'image Node.js officielle
FROM node:18-alpine AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de configuration
COPY package*.json ./

# Installer pnpm
RUN npm install -g pnpm

# Installer les dépendances
RUN pnpm install

# Copier le code source
COPY . .

# Build de l'application
RUN pnpm run build

# Stage de production
FROM node:18-alpine AS runner

WORKDIR /app

# Installer pnpm
RUN npm install -g pnpm

# Copier les fichiers de production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Installer uniquement les dépendances de production
RUN pnpm install --prod

# Exposer le port
EXPOSE 3000

# Variable d'environnement
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Commande de démarrage
CMD ["pnpm", "preview", "--host", "0.0.0.0", "--port", "3000"] 