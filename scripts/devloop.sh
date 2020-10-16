while inotifywait **/*.rb Gemfile Gemfile.shared mutant.gemspec; do
  bundle exec rspec spec/unit -fd --fail-fast --order default \
    && bundle exec ./mutant.sh --since master -- 'Mutant*' \
    && bundle exec rubocop
done
