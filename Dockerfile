# -------------------------
# Stage 1 - Build
# -------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files first (better layer caching)
COPY package*.json ./

# Install all dependencies (including devDependencies)
RUN npm ci

# Copy application source
COPY . .

# Build the Vite frontend
RUN npm run build

# -------------------------
# Stage 2 - Production
# -------------------------
FROM node:20-alpine

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev && npm cache clean --force

# Copy only the files needed at runtime
COPY index.js ./
COPY --from=builder /app/dist ./dist

# Expose Express port
EXPOSE 5000

CMD ["npm", "start"]