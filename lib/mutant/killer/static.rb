module Mutant
  class Killer
    class Static < self
      def run
        self.class::RESULT
      end

      class Success < self
        TYPE = 'success'.freeze
        RESULT = true
      end

      class Fail < self
        TYPE = 'fail'.freeze
        RESULT = false
      end
    end
  end
end
