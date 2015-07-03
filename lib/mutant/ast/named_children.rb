module Mutant
  module AST

    # Helper methods to define named children
    module NamedChildren

      # Hook called when module gets included
      #
      # @param [Class, Module] host
      #
      # @return [undefined]
      #
      # @api private
      def self.included(host)
        host.class_eval do
          include InstanceMethods
          extend ClassMethods
        end
      end

      # Methods mixed int ot instance level
      module InstanceMethods

      private

        # Mutated nodes children
        #
        # @return [Array<Parser::AST::Node]
        #
        # @api private
        def children
          node.children
        end

      end # InstanceMethods

      # Methods mixed in at class level
      module ClassMethods

      private

        # Define named child
        #
        # @param [Symbol] name
        # @param [Fixnum] index
        #
        # @return [undefined]
        #
        # @api private
        def define_named_child(name, index)
          define_method(name) do
            children.at(index)
          end
        end

        # Define remaining children
        #
        # @param [Array<Symbol>] names
        #
        # @return [undefined]
        #
        # @api private
        def define_remaining_children(names)
          define_method(:remaining_children_with_index) do
            children.each_with_index.drop(names.length)
          end

          define_method(:remaining_children_indices) do
            children.each_index.drop(names.length)
          end

          define_method(:remaining_children) do
            children.drop(names.length)
          end
        end

        # Create name helpers
        #
        # @return [undefined]
        #
        # @api private
        def children(*names)
          names.each_with_index do |name, index|
            define_named_child(name, index)
          end
          define_remaining_children(names)
        end

      end # ClassMethods
    end # NamedChildren
  end # AST
end # Mutant
