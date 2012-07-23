# encoding: utf-8

guard :bundler do
  watch('Gemfile')
end

guard :rspec do
  # run all specs if the spec_helper or supporting files files are modified
  watch('spec/spec_helper.rb')                      { 'spec' }
  watch(%r{\Aspec/(?:lib|support|shared)/.+\.rb\z}) { 'spec' }

  # run unit specs if associated lib code is modified
  watch(%r{\Alib/(.+)\.rb\z})                                         { |m| Dir["spec/unit/#{m[1]}"] }
  watch("lib/#{File.basename(File.expand_path('../', __FILE__))}.rb") { 'spec'                       }

  # run a spec if it is modified
  watch(%r{\Aspec/(?:unit|integration)/.+_spec\.rb\z})
end
