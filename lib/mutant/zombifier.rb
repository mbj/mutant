# encoding: utf-8

module Mutant
  # Zombifier namespace
  class Zombifier
    include Adamantium::Flat, Concord.new(:namespace)

    # Excluded from zombification
    IGNORE = [
      # Unparser is not performant enough (does some backtracking!) for generated lexer.rb
      'parser',
      'parser/all',
      'parser/current',
      # Wierd constant definitions / guards.
      'diff/lcs',
      'diff/lcs/hunk',
      # Mix beteen constants defined in .so and .rb files
      # Cannot be deterministically namespaced from ruby
      # without dynamically recompiling openssl ;)
      'openssl',
      # Constant propagation errors
      'thread_safe'
    ].to_set.freeze

    # Initialize object
    #
    # @param [Symbol] namespace
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(namespace)
      @namespace = namespace
      @zombified = Set.new(IGNORE)
    end

    # Perform zombification of target library
    #
    # @param [String] logical_name
    # @param [Symbol] namespace
    #
    # @api private
    #
    def self.run(logical_name, namespace)
      new(namespace).run(logical_name)
    end

    # Run zombifier
    #
    # @param [String] logical_name
    #
    # @return [undefined]
    #
    # @api private
    #
    def run(logical_name)
      highjack = RequireHighjack.new(Kernel, method(:require))
      highjack.infect
      require(logical_name)
    end

    # Require file in zombie namespace
    #
    # @param [String] logical_name
    #
    # @return [self]
    #
    # @api private
    #
    def require(logical_name)
      return if @zombified.include?(logical_name)
      @zombified << logical_name
      file = find(logical_name)
      file.zombify(namespace) if file
      self
    end

  private

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
    def find(logical_name)
      file_name =
        case File.extname(logical_name)
        when '.so'
          return
        when '.rb'
          logical_name
        else
          "#{logical_name}.rb"
        end

      $LOAD_PATH.each do |path|
        path = Pathname.new(path).join(file_name)
        return File.new(path) if path.file?
      end

      $stderr.puts "Cannot find file #{file_name} in $LOAD_PATH"
      nil
    end

  end # Zombifier
end # Mutant
