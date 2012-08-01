module Mutant
  class Mutator
    class Literal < Mutator
      # Mutator for regexp literal AST nodes
      class Regex < Literal

        handle(Rubinius::AST::RegexLiteral)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit_self('') # match all
          emit_self('a\A') # match nothing
          emit_new { new_self(Random.hex_string) }
        end

        # Return new Rubinius::AST::Regex
        #
        # @param [String] source
        #
        # @param [Integer] options
        #   options of regexp, defaults to mutation subject node options
        #
        # @return [undefined]
        #
        def new_self(source,options=nil)
          super(source,options || node.options)
        end
      end
    end
  end
end
