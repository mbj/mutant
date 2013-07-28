# encoding: utf-8

guard :bundler do
  watch('Gemfile')
  watch('Gemfile.lock')
  watch(%w{.+.gemspec\z})
end

guard :rspec, cli: File.read('.rspec').split.push('--fail-fast').join(' '), keep_failed: false do
  # Run all specs if configuration is modified
  watch('.rspec')              { 'spec' }
  watch('Guardfile')           { 'spec' }
  watch('Gemfile.lock')        { 'spec' }
  watch('spec/spec_helper.rb') { 'spec' }

  # Run all specs if supporting files files are modified
  watch(%r{\Aspec/(?:fixtures|lib|support|shared)/.+\.rb\z}) { 'spec' }

  # Run unit specs if associated lib code is modified
  watch(%r{\Alib/(.+)\.rb\z})                                         { |m| Dir["spec/unit/#{m[1]}*"]         }
  watch(%r{\Alib/(.+)/support/(.+)\.rb\z})                            { |m| Dir["spec/unit/#{m[1]}/#{m[2]}*"] }
  watch("lib/#{File.basename(File.expand_path('../', __FILE__))}.rb") { 'spec'                                }

  # Run a spec if it is modified
  watch(%r{\Aspec/(?:unit|integration)/.+_spec\.rb\z})
end

guard :rubocop, cli: %w[--config config/rubocop.yml] do
  watch(%r{.+\.(?:rb|rake)\z})
  watch(%r{\Aconfig/rubocop\.yml\z})  { |m| File.dirname(m[0]) }
  watch(%r{(?:.+/)?\.rubocop\.yml\z}) { |m| File.dirname(m[0]) }
end
