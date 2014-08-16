module Mutant
  module AST
    # Node meta information mixin
    module Meta

      REGISTRY = {}

      # Return meta for node
      #
      # @param [Parser::AST::Node] node
      #
      # @return [Meta]
      #
      # @api private
      #
      def self.for(node)
        REGISTRY.fetch(node.type, Generic).new(node)
      end

      # Mixin to define meta nodes
      class Node < Module
        include Concord.new(:type)

        CONCORD = Concord.new(:node)

        # Hook called when module gets included
        #
        # @param [Class, Module] host
        #
        # @return [undefined]
        #
        # @api private
        #
        def included(host)
          REGISTRY[type] = host
          host.class_eval do
            include CONCORD, NamedChildren
          end
        end

      end # Node

      # Metadata for resbody nods
      class Resbody
        include Node.new(:resbody)

        children :captures, :assignment, :body
      end # Resbody

      # Metadata for send nodes
      class Send
        include Node.new(:send)

        children :receiver, :selector

        INDEX_ASSIGNMENT_SELECTOR            = :[]=
        ATTRIBUTE_ASSIGNMENT_SELECTOR_SUFFIX = '='.freeze

        # Return arguments
        #
        # @return [Enumerable<Parser::AST::Node>]
        #
        # @api private
        #
        alias_method :arguments, :remaining_children

        # Test if AST node is a valid assignment target
        #
        # @return [Boolean]
        #
        # @api private
        #
        def assignment?
          index_assignment? || attribute_assignment?
        end

        # Test if AST node is an attribute assignment?
        #
        # @return [Boolean]
        #
        # @api private
        #
        def attribute_assignment?
          arguments.one? && attribute_assignment_selector?
        end

        # Test if AST node is an index assign
        #
        # @return [Boolean]
        #
        # @api private
        #
        def index_assignment?
          arguments.length.equal?(2) && index_assignment_selector?
        end

        # Test for binary operator implemented as method
        #
        # @return [Boolean]
        #
        # @api private
        #
        def binary_method_operator?
          arguments.one? && Types::BINARY_METHOD_OPERATORS.include?(selector)
        end

      private

        # Test for index assignment operator
        #
        # @return [Boolean]
        #
        # @api private
        #
        def index_assignment_selector?
          selector.equal?(INDEX_ASSIGNMENT_SELECTOR)
        end

        # Test for attribute assignment selector
        #
        # @return [Boolean]
        #
        # @api private
        #
        def attribute_assignment_selector?
          !Types::METHOD_OPERATORS.include?(selector) && selector.to_s.end_with?(ATTRIBUTE_ASSIGNMENT_SELECTOR_SUFFIX)
        end

      end # Send

      # Generic node metadata
      class Generic
        include Adamantium, Concord.new(:node)

        # Test if AST node is a valid assign target
        #
        # @return [Boolean]
        #
        # @api private
        #
        def assignment?
          Types::ASSIGNABLE_VARIABLES.include?(node.type)
        end

      end # Generic

    end #
  end # AST
end # Mutant
