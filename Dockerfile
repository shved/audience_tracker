FROM ruby:2.5.3-alpine3.8

ARG RACK_ENV
ARG RACK_ENV=production
ENV RACK_ENV $RACK_ENV

# ARG STORAGE
# ARG STORAGE='redis'
# ENV STORAGE $STORAGE

ADD Gemfile /audience_tracker/Gemfile

WORKDIR /audience_tracker

RUN set -ex && \
    apk add --no-cache g++ musl-dev make redis && \
    gem install -q --no-rdoc --no-ri bundler && \
    bundle install

COPY . /audience_tracker

# CMD ["redis-server", "--daemonize", "yes"]
CMD ["make", "run"]
