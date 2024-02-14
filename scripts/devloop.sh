while inotifywait lib/**/*.rb meta/**/*.rb spec/**/*.rb Gemfile Gemfile.shared mutant.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order defined \
    && bundle exec mutant run --since main --fail-fast --zombie -- 'Mutant*' \
    && bundle exec rubocop
done
