module Mutant
  class Zombifier
    # File containing source beeing zombified
    class File
      include NodeHelpers, Adamantium::Flat, Concord::Public.new(:path)

      # Zombify contents of file
      #
      # @return [self]
      #
      # @api private
      #
      def zombify(namespace)
        $stderr.puts("Zombifying #{path.to_s}")
        eval(
          Unparser.unparse(namespaced_node(namespace)),
          TOPLEVEL_BINDING,
          path.to_s
        )
        self
      end

      # Find file by logical path
      #
      # @param [String] logical_name
      #
      # @return [File]
      #   if found
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def self.find(logical_name)
        file_name =
          case ::File.extname(logical_name)
          when '.so'
            return
          when '.rb'
            logical_name
          else
            "#{logical_name}.rb"
          end

        $LOAD_PATH.each do |path|
          path = Pathname.new(path).join(file_name)
          return new(path) if path.file?
        end

        $stderr.puts "Cannot find file #{file_name} in $LOAD_PATH"
        nil
      end

    private

      # Return node
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def node
        Parser::CurrentRuby.parse(path.read)
      end

      # Return namespaced root
      #
      # @param [Symbol] namespace
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def namespaced_node(namespace)
        s(:module, s(:const, nil, namespace), node)
      end

    end # File
  end # Zombifier
end # Mutant
