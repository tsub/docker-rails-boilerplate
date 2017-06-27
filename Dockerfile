FROM ruby:2.4.0-alpine

ENV BUNDLE_DEPENDENCY="ruby-dev build-base" \
    RAILS_DEPENDENCY="mysql-dev nodejs tzdata" \
    EDITOR="vim"

COPY Gemfile* /app/
WORKDIR /app

RUN apk add --update --no-cache \
        ${BUNDLE_DEPENDENCY} \
        ${RAILS_DEPENDENCY} \
        # for wait-for-mysql.sh
        mysql-client \
        # for rails secrets:edit
        vim && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    /usr/local/bin/bundle install --jobs=4 --binstubs=vendor/bundle/bin --path=vendor/bundle && \
    apk del --purge \
        ${BUNDLE_DEPENDENCY}

COPY . /app/
