# For Veritas::Immutable. will be extracted soon
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
  #     def bar
  #       Mutant.not_implemented(self)
  #     end
  #   end
  #
  #   Foo.new.x # raises NotImplementedError "Foo#bar is not implemented"
  #
  # @return [undefined]
  #
  # @api private
  #
  def self.not_implemented(object)
    method = caller(1).first[/`(.*)'/,1].to_sym
    constant_name,delimiter = not_implemented_info(object)
    raise NotImplementedError,"#{constant_name}#{delimiter}#{method} is not implemented"
  end

  # Return name and delimiter
  #
  # @param [Object] object
  #
  # @return [Array]
  #
  # @api private
  #
  def self.not_implemented_info(object)
    if object.kind_of?(Module)
      [object.name,'.']
    else
      [object.class.name,'#']
    end
  end

  private_class_method :not_implemented_info
end

require 'mutant/mutator'
require 'mutant/loader'
require 'mutant/context'
require 'mutant/context/constant'
require 'mutant/mutatee'
require 'mutant/matcher'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/method/classifier'
