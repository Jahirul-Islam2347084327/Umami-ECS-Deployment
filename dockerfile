FROM node:18-alpine as builder
WORKDIR /app
RUN npm install -g pnpm
COPY ./umami/package.json ./umami/pnpm-lock.yaml ./
RUN pnpm install
COPY ./umami/ .
ENV SKIP_DB_CHECK=true
ENV DATABASE_URL=postgresql://dummy:dummy@localhost:5432/dummy
RUN pnpm run build

FROM node:18-alpine
WORKDIR /app
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package.json ./package.json
RUN chown -R node:node /app
USER node
EXPOSE 3000
CMD npx prisma migrate deploy && node server.js