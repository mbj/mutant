# frozen_string_literal: true

module Mutant
  module Procto
    # Define the .call method on +host+
    #
    # @param [Object] host
    #   the hosting object
    #
    # @return [undefined]
    #
    # @api private
    def self.included(host)
      host.extend(ClassMethods)
    end

    module ClassMethods
      def call(*)
        new(*).call
      end
    end
  end # Procto
end # Unparser
