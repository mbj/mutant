# Singleton methods are defined here so zombie can pick them up
module Mutant

  # Define instance of subclassed superclass as constant
  #
  # @param [Class] superclass
  # @param [Symbol] name
  #
  # @return [self]
  #
  # @api private
  #
  def self.singleton_subclass_instance(name, superclass, &block)
    klass = Class.new(superclass) do

      def inspect; self.class.name; end

      define_singleton_method(:name) do
        "#{superclass.name}::#{name}".freeze
      end

    end
    klass.class_eval(&block)
    superclass.const_set(name, klass.new)
    self
  end

end
