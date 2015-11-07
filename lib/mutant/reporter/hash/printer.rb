module Mutant
  class Reporter
    class Hash
      # Hash runner status printer base class
      class Printer
        include AbstractType, Delegator, Adamantium::Flat, Concord.new(:object), Procto.call(:run)

        private_class_method :new

        delegate :success?

        NL = "\n".freeze

        # Run printer
        #
        # @return [self]
        #
        # @api private
        abstract_method :run

      private

        # Visit a collection of objects
        #
        # @return [Class::Printer] printer
        # @return [Enumerable<Object>] collection
        #
        # @return [undefined]
        #
        # @api private
        def visit_collection(printer, collection)
          collection.map do |object|
            visit(printer, object)
          end
        end

        # Visit object
        #
        # @param [Class::Printer] printer
        # @param [Object] object
        #
        # @return [undefined]
        #
        # @api private
        def visit(printer, object)
          printer.call(object)
        end

      end # Printer
    end # CLI
  end # Reporter
end # Mutant
