# frozen_string_literal: true

RSpec.shared_examples_for 'framework integration' do
  def system_with_gemfile(*command)
    Kernel.system({ 'BUNDLE_GEMFILE' => gemfile }, *command)
  end

  around do |example|
    Bundler.with_clean_env do
      Dir.chdir(TestApp.root) do
        Kernel.system('bundle', 'install', '--gemfile', gemfile) || fail('Bundle install failed!')
        example.run
      end
    end
  end

  specify 'it allows to kill mutations' do
    expect(system_with_gemfile("#{base_cmd} TestApp::Literal#string")).to be(true)
  end

  specify 'it allows to exclude mutations' do
    cli = <<-CMD.split("\n").join(' ')
      #{base_cmd}
      --ignore-subject TestApp::Literal#uncovered_string
      --
      TestApp::Literal#string
      TestApp::Literal#uncovered_string
    CMD
    expect(system_with_gemfile(cli)).to be(true)
  end

  specify 'fails to kill mutations when they are not covered' do
    cli = "#{base_cmd} TestApp::Literal#uncovered_string"
    expect(system_with_gemfile(cli)).to be(false)
  end

  specify 'fails when some mutations are not covered' do
    cli = "#{base_cmd} TestApp::Literal"
    expect(system_with_gemfile(cli)).to be(false)
  end
end
