module Mutant
  module Bootstrap
    class Rails
      include Procto.call, Concord.new(:world, :config)

      def call
        world.stdout.puts('Loading mutant config from rails environment')

        # TODO add env to world.
        #
        # Make actual env configurable
        ENV['RAILS_ENV'] = 'test'

        world.kernel.require('./config/environment.rb')

        ::Rails.application.eager_load!

        # TODO: preload engines, these *love* to pack things
        # in the main project
        #
        # TODO: allow custom preload hooks.

        add_rails_matchers
      end

    private

      def add_rails_matchers
        # This logic sucks, instead rails should be come a match expression
        # possibly allow match expressions like: `ActionController.subclasses`
        return config if config.matcher.match_expressions.any?

        config.with(
          matcher: config.matcher.with(match_expressions: rails_expressions)
        )
      end

      def rails_expressions
        expressions = [
          ApplicationController,
          *ApplicationController.subclasses,
          ApplicationRecord,
          *ApplicationRecord.subclasses
        ].map { |klass| config.expression_parser.apply(klass.name).from_right }
      end

    end # Rails
  end # Bootstrap
end # Mutant
