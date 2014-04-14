# encoding: UTF-8

require 'mutant'

module Mutant
  # Minitest integration namespace
  module Minitest

    # Test if minitest integration is active
    #
    # @example
    #
    #  # test_helper.rb
    #  require 'minitest/unit'
    #
    #  unless Mutant::Minitest.active?
    #    require 'minitest/autorun'
    #  end
    #
    #  ...
    #
    # @return [Boolean]
    #
    # @api public
    #
    def self.active?
      @active
    end

    # Set minitest integration as active
    #
    # @return [self]
    #
    # @api private
    #
    def self.set_active
      @active = true
      self
    end

  end # Minitest
end # Mutant
