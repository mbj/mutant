# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      # Visual progress bar renderer
      #
      # Renders nextest-style progress bars like:
      #   45/100 (45.0%) ████████████░░░░░░░░ alive: 12 23.45s
      class ProgressBar
        include Anima.new(
          :current,
          :total,
          :width,
          :filled_char,
          :empty_char
        )

        FILLED_CHAR = "\u2588" # █
        EMPTY_CHAR  = "\u2591" # ░

        DEFAULT_WIDTH = 30

        # Render the progress bar string
        #
        # @return [String]
        def render
          "#{filled}#{empty}"
        end

        # Calculate percentage completion
        #
        # @return [Float]
        def percentage
          return 0.0 if total.zero?

          (current.to_f / total * 100)
        end

        # Build a progress bar with defaults
        #
        # @param current [Integer] current progress value
        # @param total [Integer] total value
        # @param width [Integer] bar width in characters
        #
        # @return [ProgressBar]
        def self.build(current:, total:, width: DEFAULT_WIDTH)
          new(
            current:,
            total:,
            width:,
            filled_char: FILLED_CHAR,
            empty_char:  EMPTY_CHAR
          )
        end

      private

        def filled_width
          return 0 if total.zero?

          [((current.to_f / total) * width).round, width].min
        end

        def empty_width
          [width - filled_width, 0].max
        end

        def filled
          filled_char * filled_width
        end

        def empty
          empty_char * empty_width
        end
      end # ProgressBar
    end # CLI
  end # Reporter
end # Mutant
