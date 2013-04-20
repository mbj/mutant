module Mutant
  # Abstract reporter
  class Reporter
    include Adamantium::Flat, AbstractType

    ACTIONS = {
      Subject => :subject,
    }.freeze

    # Report object
    #
    # @param [Object] object
    #
    # @return [self]
    #
    # @api private
    #
    def report(object)
      klass = object.class
      method = self.class::ACTIONS.fetch(klass) do
        raise "No reporter for: #{klass}"
      end
      send(method, object)
      self
    end

  end
end
