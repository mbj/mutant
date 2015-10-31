module Mutant
  # Zombifier namespace
  class Zombifier
    include Anima.new(
      :includes,
      :namespace,
      :load_path,
      :kernel,
      :require_highjack,
      :root_require,
      :pathname
    )
    private(*anima.attribute_names)

    include AST::Sexp

    LoadError = Class.new(::LoadError)

    # Initialize object
    #
    # @param [Symbol] namespace
    #
    # @return [undefined]
    #
    # @api private
    def initialize(*)
      super
      @includes = %r{\A#{Regexp.union(includes)}(?:/.*)?\z}
      @zombified = Set.new
    end

    # Call zombifier
    #
    # @return [self]
    #
    # @api private
    def self.call(*args)
      new(*args).__send__(:call)
      self
    end

  private

    # Run zombifier
    #
    # @return [undefined]
    #
    # @api private
    def call
      @original = require_highjack.call(method(:require))
      require(root_require)
    end

    # Test if logical name is subjected to zombification
    #
    # @param [String]
    #
    # @api private
    def include?(logical_name)
      !@zombified.include?(logical_name) && includes =~ logical_name
    end

    # Require file in zombie namespace
    #
    # @param [#to_s] logical_name
    #
    # @return [undefined]
    #
    # @api private
    def require(logical_name)
      logical_name = logical_name.to_s
      @original.call(logical_name)
      return unless include?(logical_name)
      @zombified << logical_name
      zombify(find(logical_name))
    end

    # Find file by logical path
    #
    # @param [String] logical_name
    #
    # @return [File]
    #
    # @raise [LoadError]
    #   otherwise
    #
    # @api private
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
    #
    # @api private
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
    #
    # @api private
    def namespaced_node(source_path)
      s(:module, s(:const, nil, namespace), Parser::CurrentRuby.parse(source_path.read))
    end

  end # Zombifier
end # Mutant
