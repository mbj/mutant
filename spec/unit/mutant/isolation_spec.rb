RSpec.describe Mutant::Isolation::None do
  before do
    @initial = 1
  end

  describe '.run' do
    let(:object) { described_class }

    it 'does not isolate side effects' do
      object.call { @initial = 2 }
      expect(@initial).to be(2)
    end

    it 'return block value' do
      expect(object.call { :foo }).to be(:foo)
    end

    it 'wraps *all* exceptions' do
      expect { object.call { fail  } }.to raise_error(Mutant::Isolation::Error)
    end

  end
end

RSpec.describe Mutant::Isolation::Fork do
  before do
    @initial = 1
  end

  describe '.run' do
    let(:object) { described_class }

    it 'does isolate side effects' do
      object.call { @initial = 2  }
      expect(@initial).to be(1)
    end

    it 'return block value' do
      expect(object.call { :foo }).to be(:foo)
    end

    it 'wraps exceptions' do
      expect { object.call { fail } }.to raise_error(Mutant::Isolation::Error)
    end

    it 'wraps exceptions caused by crashing ruby' do
      expect do
        object.call do
          fail RbBug.call
        end
      end.to raise_error(Mutant::Isolation::Error)
    end

    it 'redirects $stderr of children to /dev/null' do
      begin
        Tempfile.open('mutant-test') do |file|
          $stderr = file
          object.call { $stderr.puts('test') }
          file.rewind
          expect(file.read).to eql('')
        end
      ensure
        $stderr = STDERR
      end
    end

    # Spec stubbing out the fork to ensure all lines are covered
    # with expectations
    it 'covers all lines' do
      reader, writer = double('reader'), double('writer')
      expect(IO).to receive(:pipe).ordered.and_return([reader, writer])
      expect(reader).to receive(:binmode).and_return(reader).ordered
      expect(writer).to receive(:binmode).and_return(writer).ordered
      pid = double('PID')
      expect(Process).to receive(:fork).ordered.and_yield.and_return(pid)
      file = double('file')
      expect(File).to receive(:open).ordered.with('/dev/null', 'w').and_yield(file)
      expect($stderr).to receive(:reopen).ordered.with(file)
      expect(reader).to receive(:close).ordered
      expect(writer).to receive(:write).ordered.with(Marshal.dump(:foo))
      expect(writer).to receive(:close).ordered
      expect(writer).to receive(:close).ordered
      expect(reader).to receive(:read).ordered.and_return(Marshal.dump(:foo))
      expect(Process).to receive(:waitpid).with(pid)

      expect(object.call { :foo }).to be(:foo)
    end
  end
end
