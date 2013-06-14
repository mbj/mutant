module Mutant

  METHOD_POSTFIX_EXPANSIONS = {
    '?' => '_predicate',
    '=' => '_writer',
    '!' => '_bang'
  }.freeze

  BINARY_METHOD_OPERATOR_EXPANSIONS = {
    :<=>  => :spaceship_operator,
    :===  => :case_equality_operator,
    :[]=  => :element_writer,
    :[]   => :element_reader,
    :<=   => :less_than_or_equal_to_operator,
    :>=   => :greater_than_or_equal_to_operator,
    :==   => :equality_operator,
    :'!~' => :nomatch_operator,
    :'!=' => :inequality_operator,
    :=~   => :match_operator,
    :<<   => :left_shift_operator,
    :>>   => :right_shift_operator,
    :**   => :exponentation_operator,
    :*    => :multiplication_operator,
    :%    => :modulo_operator,
    :/    => :division_operator,
    :|    => :bitwise_or_operator,
    :^    => :bitwise_xor_operator,
    :&    => :bitwise_and_operator,
    :<    => :less_than_operator,
    :>    => :greater_than_operator,
    :+    => :addition_operator,
    :-    => :substraction_operator
  }.freeze

  UNARY_METHOD_OPERATOR_EXPANSIONS = {
    :~@   => :unary_match_operator,
    :+@   => :unary_addition_operator,
    :-@   => :unary_substraction_operator,
    :'!'  => :negation_operator
  }.freeze

  BINARY_METHOD_OPERATORS = BINARY_METHOD_OPERATOR_EXPANSIONS.keys.to_set.freeze

  OPERATOR_EXPANSIONS = BINARY_METHOD_OPERATOR_EXPANSIONS.merge(UNARY_METHOD_OPERATOR_EXPANSIONS).freeze
end
