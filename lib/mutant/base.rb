# frozen_string_literal: true

module Mutant
  module Functor
    include AbstractType

    abstract_method :fmap

  private

    # Raise error unless block is provided
    #
    # @raise [MissingBlockError]
    #   if no block is given
    #
    # @return [self]
    def require_block
      fail LocalJumpError unless block_given?
      self
    end
  end # Functor

  module Applicative
    include AbstractType

    abstract_method :apply # formerly known as <*>
  end # Applicative

  class Maybe
    include(
      AbstractType,
      Adamantium::Flat,
      Applicative,
      Functor
    )

    class Nothing < self
      instance = new

      define_method(:new) { instance }

      # Evaluate functor block
      #
      # @return [Maybe::Nothing]
      def fmap(&block)
        require_block(&block)
      end

      # Evaluate applicative block
      #
      # @return [Maybe::Nothing]
      def apply(&block)
        require_block(&block)
      end
    end # Nothing

    class Just < self
      include Concord.new(:value)

      # Evalute functor block
      #
      # @return [Maybe::Just<Object>]
      def fmap
        Just.new(yield(value))
      end

      # Evalute applicative block
      #
      # @return [Maybe]
      def apply
        yield(value)
      end
    end # Just
  end # Maybe

  class Either
    include(
      AbstractType,
      Adamantium::Flat,
      Applicative,
      Concord.new(:value),
      Functor
    )

    # Execute block and wrap error in left
    #
    # @param [Class:Exception] error
    #
    # @return [Either<Exception, Object>]
    def self.wrap_error(error)
      Right.new(yield)
    rescue error => exception
      Left.new(exception)
    end

    class Left < self
      # Evaluate functor block
      #
      # @return [Either::Left<Object>]
      def fmap(&block)
        require_block(&block)
      end

      # Evaluate applicative block
      #
      # @return [Either::Left<Object>]
      def apply(&block)
        require_block(&block)
      end
    end # Left

    class Right < self
      # Evaluate functor block
      #
      # @return [Either::Right<Object>]
      def fmap
        Right.new(yield(value))
      end

      # Evaluate applicative block
      #
      # @return [Either<Object>]
      def apply
        yield(value)
      end
    end # Right
  end # Either
end # Mutant
