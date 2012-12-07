module Mutant
  class Strategy 
    include AbstractType

    # Kill mutation
    #
    # @param [Mutation]
    #
    # @return [Killer]
    #
    # @api private
    #
    def self.kill(mutation)
      killer.new(self, mutation)
    end

    # Return killer
    #
    # @return [Class:Killer]
    #
    # @api private
    #
    def self.killer
      self::KILLER
    end

    # Static strategies
    class Static < self

      # Always fail to kill strategy
      class Fail < self
        KILLER = Killer::Static::Fail
      end

      # Always succeed to kill strategy
      class Success < self
        KILLER = Killer::Static::Success
      end

    end
  end
end
