RSpec.shared_examples_for 'framework integration' do
  around do |example|
    Bundler.with_clean_env do
      Dir.chdir(TestApp.root) do
        Kernel.system("bundle install --gemfile=#{gemfile}") || fail('Bundle install failed!')
        ENV['BUNDLE_GEMFILE'] = gemfile
        example.run
      end
    end
  end

  specify 'it allows to kill mutations' do
    expect(Kernel.system("#{base_cmd} TestApp::Literal#string")).to be(true)
  end

  specify 'it allows to exclude mutations' do
    cli = <<-CMD.split("\n").join(' ')
      #{base_cmd}
      --ignore-subject TestApp::Literal#uncovered_string
      TestApp::Literal#string
      TestApp::Literal#uncovered_string
    CMD

    expect(Kernel.system(cli)).to be(true)
  end

  specify 'fails to kill mutations when they are not covered' do
    cli = "#{base_cmd} TestApp::Literal#uncovered_string"
    expect(Kernel.system(cli)).to be(false)
  end

  specify 'fails when some mutations are not covered' do
    cli = "#{base_cmd} TestApp::Literal"
    expect(Kernel.system(cli)).to be(false)
  end
end
