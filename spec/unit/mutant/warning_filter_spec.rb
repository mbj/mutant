require 'spec_helper'

describe Mutant::WarningFilter do
  let(:object) { described_class.new(target) }

  let(:target) do
    writes = self.writes
    Module.new do
      define_singleton_method :write do |message|
        writes << message
      end
    end
  end

  let(:writes) { [] }

  describe '#write' do
    subject { object.write(message) }

    context 'when writing a non warning message' do
      let(:message) { 'foo' }

      it 'writes message' do
        expect { subject }.to change { writes }.from([]).to([message])
      end

      it 'does not capture warning' do
        subject
        expect(subject.warnings).to eql([])
      end
    end

    context 'when writing a warning message' do
      let(:message) { "test.rb:1: warning: some warning\n" }

      it 'captures warning' do
        expect { subject }.to change { object.warnings }.from([]).to([message])
      end

      it 'does not write message' do
        subject
        expect(writes).to eql([])
      end
    end
  end

  describe '.use' do
    let(:object) { described_class }

    it 'executes block with warning filter enabled' do
      found = false
      object.use do
        found = $stderr.kind_of?(described_class)
      end
      expect(found).to be(true)
    end

    it 'resets to original stderr after execution with exeception ' do
      original = $stderr
      begin
        object.use { fail }
      rescue
        :make_rubo_cop_happy
      end
      expect($stderr).to be(original)
    end

    it 'returns warnings generated within block' do
      warnings = object.use do
        eval(<<-RUBY)
          Class.new do
            def foo
            end

            def foo
            end
          end
        RUBY
      end
      expect(warnings).to eql(
        [
          "(eval):5: warning: method redefined; discarding old foo\n",
          "(eval):2: warning: previous definition of foo was here\n"
        ]
      )
    end

    it 'resets to original stderr after execution' do
      original = $stderr
      object.use {}
      expect($stderr).to be(original)
    end
  end
end
