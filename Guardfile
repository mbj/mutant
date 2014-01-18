# encoding: utf-8

guard :bundler do
  watch('Gemfile')
end

guard :rspec, :all_after_pass => false, :all_on_start => false, :cmd => 'bundle exec rspec --fail-fast --seed 0' do
  # run all specs if the spec_helper or supporting files files are modified
  watch('spec/spec_helper.rb')                      { 'spec/unit' }
  watch(%r{\Aspec/(?:lib|support|shared)/.+\.rb\z}) { 'spec/unit' }

  watch(%r{lib/.*.rb})                              { 'spec/unit' }

  # run a spec if it is modified
  watch(%r{\Aspec/.+_spec\.rb\z})
end
