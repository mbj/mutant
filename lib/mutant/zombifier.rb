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

    LoadError = Class.new(::LoadError)

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
    def self.call(*args)
      new(*args).__send__(:call)
      self
    end

  private

    # Original require method
    #
    # @return [Method]
    attr_reader :original

    # Run zombifier
    #
    # @return [undefined]
    def call
      @original = require_highjack.call(method(:require))
      require(root_require)
    end

    # Test if logical name is subjected to zombification
    #
    # @param [String]
    def include?(logical_name)
      !@zombified.include?(logical_name) && includes =~ logical_name
    end

    # Require file in zombie namespace
    #
    # @param [#to_s] logical_name
    #
    # @return [Bool]
    #   true if successful and false if feature already loaded
    def require(logical_name)
      logical_name = logical_name.to_s
      loaded = original.call(logical_name)
      return loaded unless include?(logical_name)
      @zombified << logical_name
      zombify(find(logical_name))
      true
    end

    # Find file by logical path
    #
    # @param [String] logical_name
    #
    # @return [File]
    #
    # @raise [LoadError]
    #   otherwise
    def find(logical_name)
      file_name = "#{logical_name}.rb"

      load_path.each do |path|
        path = pathname.new(path).join(file_name)
        return path if path.file?
      end

      fail LoadError, "Cannot find file #{file_name.inspect} in load path"
    end

    # Zombify contents of file
    #
    # Probably the 2nd valid use of eval ever. (First one is inserting mutants!).
    #
    # @param [Pathname] source_path
    #
    # @return [undefined]
    def zombify(source_path)
      kernel.eval(
        Unparser.unparse(namespaced_node(source_path)),
        TOPLEVEL_BINDING,
        source_path.to_s
      )
    end

    # Namespaced root node
    #
    # @param [Pathname] source_path
    #
    # @return [Parser::AST::Node]
    def namespaced_node(source_path)
      s(:module, s(:const, nil, namespace), ::Parser::CurrentRuby.parse(source_path.read))
    end

  end # Zombifier
end # Mutant
