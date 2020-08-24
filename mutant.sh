#/usr/bin/bash -ex

bundle exec mutant                                               \
  --since HEAD~1                                                 \
  --zombie                                                       \
  --ignore-subject Mutant::CLI#add_debug_options                 \
  --ignore-subject Mutant::Mutator::Node::Argument#skip?         \
  --ignore-subject Mutant::Mutator::Node::ProcargZero#dispatch   \
  --ignore-subject Mutant::Mutator::Node::When#mutate_conditions \
  --ignore-subject Mutant::Zombifier#call                        \
  --                                                             \
  'Mutant*'
