FROM node:18-alpine AS builder
WORKDIR /app
RUN npm install -g pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install
COPY . .
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
RUN pnpm copy-db-files
RUN pnpm prisma generate
RUN pnpm build-tracker && pnpm build-geo && pnpm build-app

FROM node:18-alpine 
RUN npm install -g pnpm
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/prisma ./prisma
RUN addgroup -g 1001 -S nodejs && \ adduser -S nodejs -u 1001 -G nodejs
RUN chown -R nodejs:nodejs /app
USER nodejs
EXPOSE 3000 
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000
CMD ["node", "server.js"]