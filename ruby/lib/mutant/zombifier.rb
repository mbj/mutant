# frozen_string_literal: true

module Mutant
  # Zombifier namespace
  class Zombifier
    include Anima.new(
      :includes,
      :load_path,
      :kernel,
      :namespace,
      :pathname,
      :require_highjack,
      :root_require
    )

    private(*anima.attribute_names)

    include AST::Sexp

    class LoadError < ::LoadError
    end

    # Initialize object
    #
    # @param [Symbol] namespace
    #
    # @return [undefined]
    def initialize(*)
      super
      @includes = %r{\A#{Regexp.union(includes)}(?:/.*)?\z}
      @zombified = Set.new
    end

    # Call zombifier
    #
    # @return [self]
    def self.call(*)
      new(*).__send__(:call)
      self
    end

  private

    attr_reader :original
    private :original
    #
    # @return [Method]

    def call
      @original = require_highjack.call(method(:require))
      require(root_require)
    end

    def include?(logical_name)
      !@zombified.include?(logical_name) && includes =~ logical_name
    end

    def require(logical_name)
      logical_name = logical_name.to_s
      loaded = original.call(logical_name)
      return loaded unless include?(logical_name)
      @zombified << logical_name
      zombify(find(logical_name))
      true
    end

    def find(logical_name)
      file_name = "#{logical_name}.rb"

      load_path.each do |path|
        path = pathname.new(path).join(file_name)
        return path if path.file?
      end

      fail LoadError, "Cannot find file #{file_name.inspect} in load path"
    end

    def zombify(source_path)
      kernel.eval(
        Unparser.unparse(namespaced_node(source_path)),
        TOPLEVEL_BINDING,
        source_path.to_s
      )
    end

    def namespaced_node(source_path)
      s(:module, s(:const, nil, namespace), Unparser.parse(source_path.read))
    end

  end # Zombifier
end # Mutant
