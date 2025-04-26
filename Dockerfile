# Stage 1 - Build
FROM node:20-slim AS builder

WORKDIR /app
COPY ./app/package*.json ./
RUN npm install 
COPY ./app .
RUN npm run build
RUN npm prune --omit=dev


# Stage 2 - Runtime
FROM node:20-slim

RUN useradd --user-group --create-home --shell /bin/false appuser

WORKDIR /home/appuser
# Bring built app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/config ./config 

# 👇 Fix ownership so appuser can read everything
RUN chown -R appuser:appuser /home/appuser

USER appuser

EXPOSE 3000

CMD ["node", "dist/index.js"]
