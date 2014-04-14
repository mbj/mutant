shared_examples_for 'mutant integration' do

  around do |example|
    Bundler.with_clean_env do
      Dir.chdir(TestApp.root) do
        Kernel.system("bundle install --gemfile=#{gemfile}")
        ENV['BUNDLE_GEMFILE'] = gemfile
        example.run
      end
    end
  end

  specify do
    expect(Kernel.system("#{base_cmd} ::TestApp::Literal#string")).to be(true)
    cli = <<-CMD.split("\n").join(' ')
      #{base_cmd}
      ::TestApp::Literal#string
      ::TestApp::Literal#uncovered_string
        --ignore-subject ::TestApp::Literal#uncovered_string
    CMD
    expect(Kernel.system(cli)).to be(true)
    cli = "#{base_cmd} ::TestApp::Literal#uncovered_string"
    expect(Kernel.system(cli)).to be(false)
    cli = "#{base_cmd} ::TestApp::Literal"
    expect(Kernel.system(cli)).to be(false)
  end

end
