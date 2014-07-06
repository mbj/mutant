module Mutant
  module AST
    # Module for node predicates
    module NodePredicates

      Types::ALL.each do |type|
        fail "method: #{type} is already defined" if instance_methods(true).include?(type)

        name = "n_#{type.to_s.chomp('?')}?"

        define_method(name) do |node|
          node.type.equal?(type)
        end
        private name
      end

    end # NodePredicates
  end # AST
end # Mutant
