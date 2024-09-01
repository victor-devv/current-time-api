FROM node:20.5.1-alpine as Base

WORKDIR /app

COPY package.json yarn.lock ./

RUN apk add --no-cache make gcc g++ python3

RUN yarn

COPY . .

FROM node:20.5.1-alpine

WORKDIR /app

COPY --from=Base /app .

CMD [ "yarn", "start" ]
