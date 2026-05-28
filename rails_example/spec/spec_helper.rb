# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
