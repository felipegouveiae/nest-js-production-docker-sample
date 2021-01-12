FROM node:12-buster as build

RUN npm i -g pnpm @nestjs/cli

WORKDIR /build

COPY package*.json ./
COPY ts*.json ./

RUN pnpm i --silent

COPY . .

RUN pnpm run build

FROM node:12-alpine

WORKDIR /app

COPY package*.json ./

RUN apk add --no-cache --virtual .gyp python make g++ \
    && npm install --production --silent \
    && apk del .gyp \
    && npm cache clear --force

COPY --from=build /build/dist /app/dist

COPY templates/ /app/templates/
COPY public/ /app/public/

ENV NODE_ENV=production
EXPOSE 8000

WORKDIR /app/dist

ENTRYPOINT ["node","main"]
