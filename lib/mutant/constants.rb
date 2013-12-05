# encoding: utf-8

module Mutant

  # Set of nodes that cannot be on the LHS of an assignment
  NOT_ASSIGNABLE = [
    :int, :float, :str, :dstr, :class, :module, :self
  ].to_set.freeze

  # Set of op-assign types
  OP_ASSIGN = [
    :or_asgn, :and_asgn, :op_asgn
  ].to_set.freeze

  # Set of node types that are not valid when emitted standalone
  NOT_STANDALONE = [:splat, :restarg, :block_pass].to_set.freeze

  # Operators ruby implementeds as methods
  METHOD_OPERATORS = %w(
    <=> === []= [] <= >= == !~ != =~ <<
    >> ** * % / | ^ & < > + - ~@ +@ -@ !
  ).map(&:to_sym).to_set.freeze

  INDEX_OPERATORS = [:[], :[]=].to_set.freeze

  UNARY_METHOD_OPERATORS = %w(
    ~@ +@ -@ !
  ).map(&:to_sym).to_set.freeze

  BINARY_METHOD_OPERATORS = (
    METHOD_OPERATORS - (INDEX_OPERATORS + UNARY_METHOD_OPERATORS)
  ).to_set.freeze

  OPERATOR_METHODS = (
    METHOD_OPERATORS + INDEX_OPERATORS + UNARY_METHOD_OPERATORS
  ).to_set.freeze

  # Hopefully all node types parser does generate.
  #
  # FIXME: Maintain this list only in unparser / parser!
  #
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
    :or_asgn, :kwbegin, :and_asgn, :while
  ].to_set.freeze

end # Mutant
