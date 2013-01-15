module Mutant
  class Strategy
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
