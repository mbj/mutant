# For Veritas::Immutable. will be extracted soon
require 'veritas'

require 'securerandom'

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

  # Return random string
  #
  # @return [String]
  #
  # @api private
  #
  def self.random_hex_string
    SecureRandom.hex(10)
  end

  # Return random fixnum
  #
  # @return [Fixnum]
  #
  # @api private
  #
  def self.random_fixnum
    Random.rand(1000)
  end

  # Return random float
  #
  # @return [Float]
  #
  # @api private
  #
  def self.random_float
    Random.rand
  end
end

require 'mutant/mutator'
require 'mutant/mutator/generator'
require 'mutant/mutator/true_literal'
require 'mutant/mutator/false_literal'
require 'mutant/mutator/symbol_literal'
require 'mutant/mutator/string_literal'
require 'mutant/mutator/fixnum_literal'
require 'mutant/mutator/float_literal'
require 'mutant/mutator/array_literal'
require 'mutant/mutator/empty_array'
require 'mutant/mutator/hash_literal'
require 'mutant/mutator/range'
require 'mutant/mutator/range_exclude'
require 'mutant/mutator/regex_literal'
require 'mutant/mutator/dynamic_string'
require 'mutant/mutator/block'
require 'mutant/loader'
require 'mutant/context'
require 'mutant/context/constant'
require 'mutant/mutatee'
require 'mutant/matcher'
require 'mutant/matcher/method'
require 'mutant/matcher/method/singleton'
require 'mutant/matcher/method/instance'
require 'mutant/matcher/method/classifier'
