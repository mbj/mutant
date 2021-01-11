while inotifywait ../unparser/**/*.rb **/*.rb Gemfile Gemfile.shared mutant.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order default \
    && bundle exec mutant run --since master --fail-fast --zombie -- 'Mutant*' \
    && bundle exec rubocop
done
