# frozen_string_literal: true

module Mutant
  class Usage
    include Adamantium, Equalizer.new

    def value
      self.class::VALUE
    end

    def verify
      Either::Right.new(nil)
    end

    def message
      self.class::MESSAGE
    end

    def merge(_other)
      self
    end

    class Commercial < self
      VALUE = 'commercial'

      MESSAGE = <<~'MESSAGE'
        ## Commercial use

        `commercial` usage type requires [payment](https://github.com/mbj/mutant?tab=readme-ov-file#pricing),
        If you are under an active payment plan you can use the commercial usage type on any
        repository, including private ones.

        To use `commercial` usage type either specify `--usage commercial` on the command
        line or use the config file key `usage`:

        ```
        # mutant.yml or config/mutant.yml
        usage: commercial
        ```
      MESSAGE
    end

    class Opensource < self
      VALUE = 'opensource'

      MESSAGE = <<~'MESSAGE'
        ## Opensource use

        `opensource` usage is free while mutant is run on an opensource project.
        Under that usage mutant does not require any kind of sign up or payment.
        Set this usage type exclusively on public opensource projects. Any other
        scenario requires payment.
        Using the `opensource` usage type on private repositories and or on commercial
        code bases is not valid.

        To use `opensource` usage type either specify `--usage opensource` on the command
        line or use the config file key `usage`:

        ```
        # mutant.yml or config/mutant.yml
        usage: opensource
        ```
      MESSAGE
    end

    class Unknown < self
      VALUE = 'unknown'

      MESSAGE = <<~"MESSAGE".freeze
        # Unknown mutant usage type

        Mutant license usage is unspecified. Valid usage types are `opensource` or `commercial`.

        Usage can be specified via the `--usage` command line parameter or via the
        config file under the `usage` key.

        #{Commercial::MESSAGE}
        #{Opensource::MESSAGE}
        This is a breaking change for users of the 0.11.x / 0.10.x mutant releases.
        Sorry for that but it's going to make future adoption much easier.
        License gem is gone entirely.
      MESSAGE

      def merge(other)
        other
      end

      def verify
        Either::Left.new(MESSAGE)
      end
    end

    def self.parse(value)
      {
        'commercial' => Either::Right.new(Commercial.new),
        'opensource' => Either::Right.new(Opensource.new)
      }.fetch(value) { Either::Left.new("Unknown usage option: #{value.inspect}") }
    end

    CLI_REGEXP = /\A(?:commercial|opensource)\z/

    TRANSFORM = Transform::Sequence.new(
      steps: [
        Transform::STRING,
        Transform::Block.capture(:environment_variables, &method(:parse))
      ]
    )
  end # Usage
end # Mutant
