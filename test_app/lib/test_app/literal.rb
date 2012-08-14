module TestApp
  # Class for integration testing literal mutations
  class Literal
    def boolean
      true
    end

    def self.freeze
      raise
    end

    def string
      'string'
    end

    def uncovered_string
      'string'
    end

    def self.string
      'string'
    end

    def symbol
      :symbol
    end

    def float
      2.4
    end
  end
end
