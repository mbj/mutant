while inotifywait lib/**/*.rb spec/**/*.rb Gemfile Gemfile.shared mutant.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order default \
    && bundle exec mutant run --since main --fail-fast --zombie -- 'Mutant*' \
    && bundle exec rubocop
done
