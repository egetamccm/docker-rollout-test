FROM cgr.dev/chainguard/node:latest-dev AS build

WORKDIR /usr/src/app

# Use lockfile for deterministic installs and better supply-chain hygiene.
COPY app/package*.json ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

COPY app/. ./

FROM gcr.io/distroless/nodejs20-debian12:nonroot

ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /usr/src/app

COPY --from=build /usr/src/app /usr/src/app

EXPOSE 3000

HEALTHCHECK --interval=5s --timeout=3s --retries=5 CMD ["node", "healthcheck.js"]

CMD ["server.js"]
