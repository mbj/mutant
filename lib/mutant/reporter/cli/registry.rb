module Mutant
  class Reporter
    class CLI
      # Mixin to generate registry semantics
      class Registry < Module
        include Concord.new(:registry)

        # Return new registry
        #
        # @return [Registry]
        #
        # @api private
        #
        def self.new
          super({})
        end

        # Register handler for class
        #
        # @param [Class] klass
        #
        # @return [self]
        #
        # @api private
        #
        def handle(subject, handler)
          raise "Duplicate registration of #{subject}" if registry.key?(subject)
          registry[subject] = handler
          self
        end

        # Lookup handler
        #
        # @param [Class] subject
        #
        # @return [Object]
        #   if found
        #
        # @raise [RuntimeError]
        #   otherwise
        #
        # @api private
        #
        def lookup(subject)
          current = subject
          until current.equal?(Object)
            if registry.key?(current)
              return registry.fetch(current)
            end
            current = current.superclass
          end
          raise "No printer for: #{subject}"
        end

        # Hook called when module is included
        #
        # @param [Class,Module] host
        #
        # @return [undefined]
        #
        def included(host)
          object = self
          host.class_eval do
            define_singleton_method(:lookup, &object.method(:lookup))
            private_class_method :lookup

            define_singleton_method(:handle) do |subject|
              object.handle(subject, self)
            end
            private_class_method :handle
          end
        end

      end # Registry
    end # CLI
  end # Reporter
end # Mutant
