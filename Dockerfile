ARG RUBY_VERSION=3.3
FROM ruby:${RUBY_VERSION}-slim

WORKDIR /app

# Install gems into a container-owned path *outside* /app. `make docker-shell`
# bind-mounts the host checkout over /app; if the bundle lived under /app
# (e.g. /app/vendor/bundle) that mount would shadow it and `bundle exec` would
# fail. Keeping gems and Bundler config under /usr/local/bundle survives the mount.
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle

RUN apt-get update \
  && apt-get install --no-install-recommends -y build-essential git \
  && rm -rf /var/lib/apt/lists/*

ARG BUNDLER_VERSION
RUN if [ -n "$BUNDLER_VERSION" ]; then gem install bundler -v "$BUNDLER_VERSION"; fi

ARG BUNDLE_GEMFILE=Gemfile.docker

COPY . /app

ENV BUNDLE_GEMFILE=/app/${BUNDLE_GEMFILE}

RUN bundle install --jobs 4 --retry 3

CMD ["bundle", "exec", "rspec", "spec/lib"]
