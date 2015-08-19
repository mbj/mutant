module Mutant
  module AST
    # Node meta information mixin
    module Meta

      # Metadata for resbody nods
      class Resbody
        include NamedChildren, Concord.new(:node)

        children :captures, :assignment, :body
      end # Resbody

      # Metadata for optional argument nodes
      class Optarg
        include NamedChildren, Concord.new(:node)

        UNDERSCORE = '_'.freeze

        children :name, :default_value

        # Test if optarg definition intends to be used
        #
        # @return [Boolean]
        #
        # @api private
        def used?
          !name.to_s.start_with?(UNDERSCORE)
        end
      end # Optarg

      # Metadata for send nodes
      class Send
        include NamedChildren, Concord.new(:node)

        children :receiver, :selector

        INDEX_ASSIGNMENT_SELECTOR            = :[]=
        ATTRIBUTE_ASSIGNMENT_SELECTOR_SUFFIX = '='.freeze

        # Arguments of mutated node
        #
        # @return [Enumerable<Parser::AST::Node>]
        #
        # @api private
        alias_method :arguments, :remaining_children

        # Test if AST node is a valid assignment target
        #
        # @return [Boolean]
        #
        # @api private
        def assignment?
          index_assignment? || attribute_assignment?
        end

        # Test if AST node is an attribute assignment?
        #
        # @return [Boolean]
        #
        # @api private
        def attribute_assignment?
          !Types::METHOD_OPERATORS.include?(selector) &&
          selector.to_s.end_with?(ATTRIBUTE_ASSIGNMENT_SELECTOR_SUFFIX)
        end

        # Test if AST node is an index assign
        #
        # @return [Boolean]
        #
        # @api private
        def index_assignment?
          selector.equal?(INDEX_ASSIGNMENT_SELECTOR)
        end

        # Test for binary operator implemented as method
        #
        # @return [Boolean]
        #
        # @api private
        def binary_method_operator?
          Types::BINARY_METHOD_OPERATORS.include?(selector)
        end

      end # Send
    end # Meta
  end # AST
end # Mutant
