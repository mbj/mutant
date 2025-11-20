module TestApp
  # Class for integration testing literal mutations
  class Literal
    def boolean
      true
    end

    def command(_foo)
      self
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

  class Empty
  end
end
