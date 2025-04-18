#!/usr/bin/env bash
# exit on error
set -o errexit

node -v
npm -v
gem install rails -v 8.0.1
bundle install
chmod +x bin/*
bundle exec rails assets:precompile
bundle exec rails assets:clean

bundle exec rails db:migrate

# If you're using a Free instance type, you need to
# perform database migrations in the build command.
# Uncomment the following line:s

# bundle exec rails db:migrate