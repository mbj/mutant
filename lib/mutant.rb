# For Veritas::Immutable will be extracted soon
require 'veritas'

# Library namespace
module Mutant
  # Helper method for raising not implemented exceptions
  #
  # @param [Object] object
  #   the object where method is not implemented
  #
  # @raise [NotImplementedError]
  #   raises a not implemented error with correct description
  #
  # @example
  #   class Foo
  #     def x
  #       Mutant.not_implemented(self)
  #     end
  #   end
  #
  #   Foo.new.x # raises NotImplementedError "Foo#x is not implemented"
  #
  # @return [undefined]
  #
  # @api private
  def self.not_implemented(object)
    method = caller(1).first[/`(.*)'/,1].to_sym
    delimiter = object.kind_of?(Module) ? '.' : '#'
    raise NotImplementedError,"#{object.class}#{delimiter}#{method} is not implemented"
  end
end

require 'mutant/matcher'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/method/classifier'
