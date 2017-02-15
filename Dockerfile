FROM ruby:2.4.0-alpine

ENV BUNDLE_DEPENDENCY="ruby-dev build-base" \
    RAILS_DEPENDENCY="mysql-dev nodejs"

COPY Gemfile* /app/
WORKDIR /app

RUN apk add --update --no-cache \
        ${BUNDLE_DEPENDENCY} \
        ${RAILS_DEPENDENCY} \
        tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    /usr/local/bin/bundle install --jobs=4 && \
    apk del --purge \
        ${BUNDLE_DEPENDENCY}

COPY . /app/
