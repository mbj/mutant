RSpec.describe Mutant::Isolation::Fork, mutant: false do
  def apply(&block)
    Mutant::Config::DEFAULT.isolation.call(&block)
  end

  it 'does isolate side effects' do
    initial = 1
    apply { initial = 2  }
    expect(initial).to be(1)
  end

  it 'return block value' do
    expect(apply { :foo }).to be(:foo)
  end

  it 'wraps exceptions' do
    expect { apply { fail } }.to raise_error(Mutant::Isolation::Error)
  end

  it 'wraps exceptions caused by crashing ruby' do
    expect do
      apply { fail RbBug.call }
    end.to raise_error(Mutant::Isolation::Error)
  end

  it 'redirects $stderr of children to /dev/null' do
    begin
      Tempfile.open('mutant-test') do |file|
        $stderr = file
        apply { $stderr.puts('test') }
        expect(file.read).to eql('')
      end
    ensure
      $stderr = STDERR
    end
  end

  it 'redirects $stdout of children to /dev/null' do
    begin
      Tempfile.open('mutant-test') do |file|
        $stdout = file
        apply { $stdout.puts('test') }
        expect(file.read).to eql('')
      end
    ensure
      $stderr = STDOUT
    end
  end
end
