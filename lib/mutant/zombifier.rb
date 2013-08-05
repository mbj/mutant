# encoding: utf-8

module Mutant
  # Zombifier namespace
  module Zombifier

    # Excluded from zombification, reasons
    #
    # * Relies dynamic require, zombifier does not know how to recurse (racc)
    # * Unparser bug (optparse)
    # * Toplevel reference/cbase nodes in code (rspec)
    # * Creates useless toplevel modules that get vendored under ::Zombie (set)
    #
    STOP = %w(
      set
      rspec
      diff/lcs
      diff/lcs/hunk
      parser
      parser/all
      parser/current
      racc/parser
      optparse
    ).to_set

    # Perform self zombification
    #
    # @return [self]
    #
    # @api private
    #
    def self.zombify
      run('mutant')
    end

    # Zombify gem
    #
    # @param [String] name
    #
    # @return [self]
    #
    # @api private
    #
    def self.run(name)
      Gem.new(name).zombify
    end

    # Zombifier subject, compatible with mutants loader
    class Subject < Mutant::Subject
      include NodeHelpers

      # Return new object
      #
      # @param [File]
      #
      # @return [Subject]
      #
      # @api private
      #
      def self.new(file)
        super(file, file.node)
      end

      # Perform zombification on subject
      #
      # @return [self]
      #
      # @api private
      #
      def zombify
        $stderr.puts "Zombifying #{context.source_path}"
        Loader::Eval.run(zombified_root, self)
        self
      end
      memoize :zombify

    private

      # Return zombified root
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def zombified_root
        s(:module, s(:const, nil, :Zombie), node)
      end

    end # Subject

    # File containing source beeing zombified
    class File
      include Adamantium::Flat, Concord::Public.new(:source_path)

      CACHE = {}

      # Zombify contents of file
      #
      # @return [self]
      #
      # @api private
      #
      def zombify
        subject.zombify
        required_paths.each do |path|
          file = File.find(path)
          next unless file
          file.zombify
        end
        self
      end

      # Find file
      #
      # @param [String] logical_name
      #
      # @return [File]
      #   if found
      #
      # @raise [RuntimeError]
      #   if file cannot be found
      #
      # @api private
      #
      def self.find(logical_name)
        return if STOP.include?(logical_name)
        CACHE.fetch(logical_name) do
          CACHE[logical_name] = find_uncached(logical_name)
        end
      end

      # Find file without cache
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
      def self.find_uncached(logical_name)
        file_name =
          if logical_name.end_with?('.rb')
            logical_name
          else
            "#{logical_name}.rb"
          end

        $LOAD_PATH.each do |path|
          path = Pathname.new(path).join(file_name)
          if path.file?
            return new(path)
          end
        end

        $stderr.puts "Cannot find file #{file_name} in $LOAD_PATH"
        nil
      end

      # Return subject
      #
      # @return [Subject]
      #
      # @api private
      #
      def subject
        Subject.new(self)
      end
      memoize :subject

      # Return node
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      def node
        Parser::CurrentRuby.parse(::File.read(source_path))
      end
      memoize :node

      RECEIVER_INDEX = 0
      SELECTOR_INDEX = 1
      ARGUMENT_INDEX = 2..-1.freeze

      # Return required paths
      #
      # @return [Enumerable<String>]
      #
      # @api private
      #
      def required_paths
        require_nodes.map do |node|
          arguments = node.children[ARGUMENT_INDEX]
          unless arguments.length == 1
            raise "Require node with not exactly one argument: #{node}"
          end
          argument = arguments.first
          unless argument.type == :str
            raise "Require argument is not a literal string: #{argument}"
          end
          argument.children.first
        end
      end
      memoize :required_paths

    private

      # Return require nodes
      #
      # @return [Enumerable<Parser::AST::Node>]
      #
      # @api private
      #
      def require_nodes
        children = node.type == :begin ? node.children : [node]
        children.select do |node|
          children = node.children
          node.type == :send &&
          children.at(RECEIVER_INDEX).nil? &&
          children.at(SELECTOR_INDEX) == :require
        end
      end

    end # File

    # Gem beeing zombified
    class Gem
      include Adamantium::Flat, Concord.new(:name)

      # Return subjects
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      #
      def zombify
        root_file.zombify
      end
      memoize :zombify

    private

      # Return root souce file
      #
      # @return [File]
      #
      # @api private
      #
      def root_file
        File.find(name) or raise 'No root file!'
      end
      memoize :root_file

    end # Gem

  end # Zombifier
end # Mutant
