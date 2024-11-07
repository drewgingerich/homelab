ARG TANDOOR_VERSION=1.2.7

FROM node AS web-build

RUN npm install --global yarn

FROM python

RUN apk add --update --no-cache curl libpq-dev postgresql libsasl2-dev python-dev libldap2-dev libssl-dev

RUN curl https://github.com/TandoorRecipes/recipes/archive/refs/tags/${TANDOOR_VERSION}.tar.gz
