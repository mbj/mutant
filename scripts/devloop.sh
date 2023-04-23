while inotifywait lib/**/*.rb meta/**/*.rb spec/**/*.rb Gemfile Gemfile.shared mutant.gemspec; do
  bundle exec mutant environment test run --fail-fast spec/unit \
    && bundle exec mutant run --fail-fast --since main --zombie -- 'Mutant*' \
    && bundle exec rubocop
done
