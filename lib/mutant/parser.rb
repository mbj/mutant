# frozen_string_literal: true

module Mutant
  # An AST Parser
  class Parser
    include Adamantium, Equalizer.new

    # Initialize object
    #
    # @return [undefined]
    def initialize
      @cache = {}
    end

    # Parse path into AST
    #
    # @param [Pathname] path
    #
    # @return [AST::Node]
    def call(path)
      @cache[path] ||= parse(path.read)
    end

  private

    def parse_cached(source)
      path = "cache-#{key(source)}"

      if File.exist?(path)
        Marshal.load(File.binread(path))
      else
        Unparser.parse_with_comments(source).tap do |value|
          File.binwrite(path, Marshal.dump(value))
        end
      end
    end

    def key(source)
      [
        RUBY_VERSION,
        ::Parser::VERSION,
        Digest::SHA256.hexdigest(source),
      ].join('-')
    end

    def parse(source)
      node, comments = parse_cached(source)

      AST.new(
        node:                 node,
        comment_associations: ::Parser::Source::Comment.associate_by_identity(node, comments)
      )
    end

  end # Parser
end # Mutant
