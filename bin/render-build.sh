set -o errexit

bundle install

npm install
npx @tailwindcss/cli -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --minify
npx esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets

bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
# bundle exec rails db:seed
