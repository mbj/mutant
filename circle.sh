#!/bin/bash

# Strict mode

set -o errexit    # Exit when an expression fails
set -o pipefail   # Exit when a command in a pipeline fails
set -o nounset    # Exit when an undefined variable is used
set -o noglob     # Disable shell globbing
set -o noclobber  # Disable automatic file overwriting
set -o posix      # Ensure posix semantics

IFS=$'\n\t'  # Set default field separator to not split on spaces

umask 0077

# Run all metric tasks except for integration tests
metrics(){
  bundle exec rake           \
    metrics:coverage         \
    metrics:yardstick:verify \
    metrics:rubocop          \
    metrics:flog             \
    metrics:flay             \
    metrics:reek             \
    metrics:mutant
}

CORPUS_SPEC=spec/integration/mutant/corpus_spec.rb
CORPUS_SPEC_FILENAME=$(basename "$CORPUS_SPEC")

# Check to make sure corpus spec is where we think so CI doesn't silently slow down
if [ ! -f "$CORPUS_SPEC" ]; then
  echo "Expected corpus spec file to exist at $CORPUS_SPEC"
  exit 1
fi

# List all integration test files excluding the corpus spec
integration_test_files(){
  find spec/integration -type f -name '*_spec.rb' ! -name "$CORPUS_SPEC_FILENAME"
}

# Run all integration tests except for corpus specs
integration_tests(){
  integration_test_files | xargs bundle exec rspec
}

# Run only the corpus specs
corpus_tests(){
  bundle exec rspec "$CORPUS_SPEC"
}

invalid_node_index(){
  echo "Expected CIRCLE_NODE_INDEX to be 0 or 1"
  exit 1
}

if [ "$CIRCLE_NODE_TOTAL" -ne 2 ]; then
  echo "$0 expects CIRCLE_NODE_INDEX to be 2 but instead found $CIRCLE_NODE_INDEX"
  exit 1
fi

case $CIRCLE_NODE_INDEX in
  0) metrics; integration_tests ;;
  1) corpus_tests               ;;
  *) invalid_node_index         ;;
esac
