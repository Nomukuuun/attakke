set -o errexit

bundle install

bundle exec rails tailwindcss:build
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
