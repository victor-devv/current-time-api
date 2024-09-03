FROM node:20.5.1-alpine AS base

WORKDIR /app

COPY package.json yarn.lock ./

RUN apk add --no-cache make gcc g++ python3

RUN yarn

COPY . .

RUN yarn build:tsc

FROM node:20.5.1-alpine

WORKDIR /app

COPY --from=base /app .

CMD [ "yarn", "start" ]
