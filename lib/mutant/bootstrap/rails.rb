module Mutant
  module Bootstrap
    module Rails
      def self.call(world, config)
        world.stdout.puts('Loading mutant config from rails environment')

        # TODO move to world.
        ENV['RAILS_ENV'] = 'test'

        world.kernel.require('./config/environment.rb')

        ::Rails.application.eager_load!

        expressions = [
          ApplicationController,
          *ApplicationController.subclasses,
          ApplicationRecord,
          *ApplicationRecord.subclasses
        ].map { |klass| config.expression_parser.apply(klass.name).from_right }

        config.with(
          matcher: config.matcher.with(
            match_expressions: config.matcher.match_expressions | expressions
          )
        )
      end
    end # Rails
  end # Bootstrap
end # Mutant
