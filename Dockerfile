# Base image with dependencies
FROM ruby:3.2.7 AS base

# Install system dependencies (add libvips42 for ActiveStorage variants)
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  sqlite3 \
  libyaml-dev \
  libvips42

# Set working directory
WORKDIR /rails

# Set bundler environment variables
ENV BUNDLE_PATH=/gems \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Copy only Gemfile(s) first to leverage Docker layer caching
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Builder stage for asset precompilation
FROM base AS builder

# Fake ENV vars for build-time asset precompilation
ENV STRIPE_SECRET_KEY=dummy_secret \
    STRIPE_PUBLIC_KEY=dummy_public \
    RAILS_ENV=production \
    SECRET_KEY_BASE_DUMMY=1

# Copy full app AFTER installing gems to preserve cache
COPY . .

# Precompile assets and bootsnap cache
RUN bundle exec bootsnap precompile app/ lib/ && \
    ./bin/rails assets:precompile && \
    rm -rf tmp/cache

# Final runtime stage (slim and secure)
FROM ruby:3.2.7

# Install libvips for image processing (e.g., ActiveStorage)
RUN apt-get update -qq && apt-get install -y libvips42

COPY --from=builder /gems /gems
COPY --from=builder /rails /rails

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_PATH=/gems

# Permissions and assets
RUN mkdir -p /rails/public/assets && chmod -R 755 /rails/public

# Start the server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
