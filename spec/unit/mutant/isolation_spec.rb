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
      expect { object.call { fail } }.to raise_error(Mutant::Isolation::Error, 'marshal data too short')
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

    context 'uses primitives in correct order' do
      let(:reader) { instance_double(IO) }
      let(:writer) { instance_double(IO) }

      before do
        expect(IO).to receive(:pipe).with(binmode: true).ordered do |&block|
          block.call([reader, writer])
        end
        expect(writer).to receive(:binmode).ordered
      end

      it 'when fork succeeds' do
        pid = instance_double(Fixnum)
        expect(Process).to receive(:fork).ordered.and_yield.and_return(pid)
        file = instance_double(File)
        expect(File).to receive(:open).ordered
          .with(File::NULL, File::WRONLY).and_yield(file)
        expect($stderr).to receive(:reopen).ordered.with(file)
        expect(reader).to receive(:close).ordered
        expect(writer).to receive(:write).ordered.with(Marshal.dump(:foo))
        expect(writer).to receive(:close).ordered
        expect(writer).to receive(:close).ordered
        expect(reader).to receive(:read).ordered.and_return(Marshal.dump(:foo))
        expect(Process).to receive(:waitpid).with(pid)

        expect(object.call { :foo }).to be(:foo)
      end

      it 'when fork fails' do
        expect(Process).to receive(:fork).ordered.and_return(nil)
        expect(Process).to_not receive(:waitpid)
        expect(writer).to receive(:close).ordered
        expect(reader).to receive(:read).ordered.and_return(Marshal.dump(:foo))
        expect(object.call).to be(:foo)
      end
    end
  end
end
