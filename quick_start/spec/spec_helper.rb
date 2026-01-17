# frozen_string_literal: true

if ENV['SIMPLECOV']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    enable_coverage :branch
  end
end
