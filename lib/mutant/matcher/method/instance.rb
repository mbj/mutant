module Mutant
  class Matcher
    class Method < self
      # Matcher for instance methods
      class Instance < self

        # Extract instance method matchers from scope
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Matcher::Method::Instance>]
        #
        # @api private
        #
        def self.each(scope)
          return to_enum(:each, scope) unless block_given?
          return unless scope.kind_of?(Module)

          instance_method_names(scope).map do |name|
            yield new(scope, name)
          end
        end

        # Return instance methods names of scope
        #
        # @param [Class|Module] scope
        #
        # @return [Enumerable<Symbol>]
        #
        def self.instance_method_names(scope)
          names = 
            scope.public_instance_methods(false)  +
            scope.private_instance_methods(false) + 
            scope.protected_instance_methods(false)

          names.uniq.map(&:to_sym).sort
        end

        # Return identification
        #
        # @return [String]
        #
        # @api private
        #
        def identification
          "#{scope.name}##{method_name}"
        end

      private

        # Check if node is matched
        #
        # @param [Rubinius::AST::Node] node
        #
        # @return [true]
        #   returns true if node matches method
        #
        # @return [false]
        #   returns false if node NOT matches method
        #
        # @api private
        #
        def match?(node)
          node.line  == source_line &&
          node.class == Rubinius::AST::Define  &&
          node.name  == method_name
        end

        # Return method instance
        #
        # @return [UnboundMethod]
        #
        # @api private
        #
        def method
          scope.instance_method(method_name)
        end
        memoize :method

      end
    end
  end
end
