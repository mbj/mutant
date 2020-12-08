#/usr/bin/bash -ex

bundle exec mutant run                                           \
  --zombie                                                       \
  --ignore-subject Mutant::CLI#add_debug_options                 \
  --ignore-subject Mutant::Isolation::Fork::Parent#call          \
  --ignore-subject Mutant::Mutator::Node::Argument#skip?         \
  --ignore-subject Mutant::Mutator::Node::ProcargZero#dispatch   \
  --ignore-subject Mutant::Mutator::Node::When#mutate_conditions \
  --ignore-subject Mutant::Zombifier#call                        \
  $*
