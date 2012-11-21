module Zombie
  # Setup zombie
  #
  # @return [self]
  #
  # @api private
  #
  def self.setup
    files.each do |path|
      path = "#{File.expand_path(path, root)}.rb"
      ast = File.read(path).to_ast
      zombify(ast, path)
    end

    self
  end

  # Return library root directory
  #
  # @return [String]
  #
  # @api private
  #
  def self.root
    File.expand_path('../../../lib',__FILE__)
  end
  private_class_method :root


  # Replace Mutant with Zombie namespace
  #
  # @param [Rubinius::AST::Node]
  #
  # @api private
  #
  # @return [undefined]
  #
  def self.zombify(root, path)
    node = find_mutant(root)
    unless node
      raise "unable to find mutant in AST from: #{path.inspect}"
    end

    name = node.name

    node.name = Rubinius::AST::ModuleName.new(name.line, :Zombie)

    scope = node.body

    unless scope.kind_of?(Rubinius::AST::EmptyBody)
      node.body = Rubinius::AST::ModuleScope.new(scope.line, node.name, scope.body)
    end

    ::Mutant::Loader::Eval.run(root)
  end
  private_class_method :zombify

  # Find mutant module in AST
  #
  # @param [Rubinius::AST::Node]
  #
  # @return [Rubinius::AST::Node]
  #
  def self.find_mutant(root)
    if is_mutant?(root)
      return root
    end

    unless root.kind_of?(Rubinius::AST::Block)
      raise "Cannot find mutant in: #{root.class}"
    end

    root.array.each do |node|
      return node if is_mutant?(node)
    end

    nil
  end
  private_class_method :find_mutant

  # Test if node is mutant module
  #
  # @param [Rubinius::AST::Node]
  #
  # @return [true]
  #   returns true if node is the mutant module
  #
  # @return [false]
  #   returns false otherwise
  #
  # @api private
  #
  def self.is_mutant?(node)
    node.kind_of?(Rubinius::AST::Module) && is_mutant_name?(node.name)
  end
  private_class_method :is_mutant?

  # Test if node is mutant module name
  #
  # @param [Rubinius::AST::ModuleName]
  #
  # @return [true]
  #   returns true if node is the mutant module name
  #
  # @return [false]
  #   returns false otherwise
  #
  # @api private
  #
  def self.is_mutant_name?(node)
    node.name == :Mutant
  end
  private_class_method :is_mutant_name?

  # Return all library files the mutant is made of.
  #
  # @return [Array<String>]
  #
  # @api private
  #
  # FIXME: 
  #  Yeah looks very ugly but im currently to exited to do a cleanup.
  #
  def self.files
    block = File.read("lib/mutant.rb").to_ast
    files = block.array.select do |node|
      node.class          == Rubinius::AST::SendWithArguments &&
      node.receiver.class == Rubinius::AST::Self              &&
      node.name           == :require
    end.map do |node|
      arguments = node.arguments.array
      raise unless arguments.one?
      argument = arguments.first
      raise unless argument.class == Rubinius::AST::StringLiteral
      argument.string
    end.select do |file|
      file =~ /\Amutant/
    end
  end
  private_class_method :files
end
