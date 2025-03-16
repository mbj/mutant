# frozen_string_literal: true

RSpec.shared_examples_for 'framework integration' do
  def system_with_gemfile(*command)
    Kernel.system(
      {
        'CI'             => '1',
        'BUNDLE_GEMFILE' => gemfile
      },
      *command
    )
  end

  around do |example|
    Bundler.with_unbundled_env do
      Dir.chdir(TestApp.root) do
        Kernel.system(*p('bundle', 'install', '--gemfile', gemfile)) || fail('Bundle install failed!')
        example.run
      end
    end
  end

  let(:effective_base_cmd) do
    if ENV.key?('MUTANT_JOBS')
      [*base_cmd, '--jobs', ENV.fetch('MUTANT_JOBS')]
    else
      base_cmd
    end
  end

  specify 'it allows to kill mutations' do
    expect(
      system_with_gemfile(
        *effective_base_cmd,
        'TestApp::Literal#string'
      )
    ).to be(true)
  end

  specify 'it allows to exclude mutations' do
    expect(
      system_with_gemfile(
        *effective_base_cmd,
        '--ignore-subject',
        'TestApp::Literal#uncovered_string',
        '--',
        'TestApp::Literal#string',
        'TestApp::Literal#uncovered_string'
      )
    ).to be(true)
  end

  specify 'fails to kill mutations when they are not covered' do
    expect(
      system_with_gemfile(
        *effective_base_cmd,
        'TestApp::Literal#uncovered_string'
      )
    ).to be(false)
  end

  specify 'fails when some mutations are not covered' do
    expect(
      system_with_gemfile(
        *effective_base_cmd,
        'TestApp::Literal'
      )
    ).to be(false)
  end
end
