module Mutant

  METHOD_POSTFIX_EXPANSIONS = {
    '?' => '_predicate',
    '=' => '_writer',
    '!' => '_bang'
  }.freeze

  # Set of not assignable nodes
  NOT_ASSIGNABLE = [
    :int, :float, :str, :dstr, :class, :module, :self
  ].to_set.freeze

  # Set of op assign types
  OP_ASSIGN = [
    :or_asgn, :and_asgn
  ].to_set.freeze

  # Set of node types that are not valid when emitted standalone
  NOT_STANDALONE = [ :splat, :block_pass ].to_set.freeze

  OPERATOR_EXPANSIONS = {
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
    :-    => :substraction_operator,
    :~@   => :unary_match_operator,
    :+@   => :unary_addition_operator,
    :-@   => :unary_substraction_operator,
    :'!'  => :negation_operator
  }.freeze

  INDEX_OPERATORS = [ :[], :[]= ].freeze

  UNARY_METHOD_OPERATORS = [
    :~@, :+@, :-@, :'!'
  ].freeze

  BINARY_METHOD_OPERATORS = (
    OPERATOR_EXPANSIONS.keys - (INDEX_OPERATORS + UNARY_METHOD_OPERATORS)
  ).to_set.freeze

  OPERATOR_METHODS =
    OPERATOR_EXPANSIONS.keys + INDEX_OPERATORS + UNARY_METHOD_OPERATORS

  # Hopefully all types parser does generate
  NODE_TYPES = [
    :lvasgn, :ivasgn, :cvasgn, :gvasgn,
    :casgn, :masgn, :mlhs, :break, :rescue,
    :ensure, :resbody, :begin, :retry, :arg_expr,
    :args, :blockarg, :optarg, :kwrestarg, :kwoptarg,
    :kwarg, :restarg, :arg, :block_pass, :or, :and,
    :next, :undef, :if, :module, :cbase, :block, :send,
    :zsuper, :super, :empty, :alias, :for, :redo,
    :return, :splat, :defined?, :op_asgn, :self,
    :true, :false, :nil, :dstr, :dsym, :regexp,
    :regopt, :int, :str, :float, :sym, :pair, :hash, :array,
    :xstr, :def, :defs, :case, :when, :ivar, :lvar, :cvar, :gvar,
    :back_ref, :const, :nth_ref, :class, :sclass, :yield,
    :match_with_lvasgn, :match_current_line, :irange, :erange,
    :or_asgn, :kwbegin, :and_asgn
  ].to_set.freeze

end # Mutant
