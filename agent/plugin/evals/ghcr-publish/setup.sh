#!/bin/sh
# A minimal GhentCDH project with a Dockerfile and no workflows yet.
set -eu
git init -q
git remote add origin git@github.com:GhentCDH/Example-App.git
cat > Dockerfile <<'DOCKERFILE'
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
DOCKERFILE
printf '{"name":"example-app","scripts":{"build":"mkdir -p dist && echo ok > dist/index.html"}}\n' > package.json
