module Mutant
  # Module to declare abstract methods
  module Abstract

    # Declare abstract instance method
    #
    # @return [self]
    #
    # @api private
    #
    def abstract(*names)
      names.each do |name|
        define_instance_method(name)
      end

      self
    end

    # Declare abstract singleton method
    #
    # @return [self]
    #
    # @api private
    #
    def abstract_singleton(*names)
      names.each do |name|
        define_singleton_method(name)
      end

      self
    end

  private

    # Define abstract method stub on singleton
    #
    # @param [String] name
    #
    # @return [undefined]
    #
    # @api private
    #
    def define_singleton_method(name)
      class_eval(<<-RUBY,__FILE__,__LINE__+1)
        def #{name}(*)
          raise NotImplementedError,"\#{self.name}.\#{__method__} is not implemented"
        end
      RUBY
    end

    # Define abstract method stub on instances
    #
    # @param [String] name
    #
    # @return [undefined]
    #
    # @api private
    #
    def define_instance_method(name)
      class_eval(<<-RUBY,__FILE__,__LINE__+1)
        def #{name}(*)
          raise NotImplementedError,"\#{self.class.name}#\#{__method__} is not implemented"
        end
      RUBY
    end
  end
end
