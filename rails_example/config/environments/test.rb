# frozen_string_literal: true

Rails.application.configure do
  config.eager_load = true
  config.consider_all_requests_local = true
  config.active_support.deprecation = :stderr
end
