RSpec.describe Mutant::Reporter::CLI::Printer do
  let(:output) { StringIO.new }

  subject { class_under_test.call(output, reportable) }

  def self.it_reports(expectation)
    it 'writes expected report' do
      allow(output).to receive(:tty?).and_return(tty?)
      subject
      output.rewind
      expect(output.read).to eql(strip_indent(expectation))
    end
  end

  let(:reportable) { instance_double(Mutant::Result::Env, success?: success?) }
  let(:tty?)       { true                                                     }
  let(:success?)   { true                                                     }

  describe '.call' do
    let(:class_under_test) do
      Class.new(described_class) do
        def run
          puts object
        end
      end
    end

    let(:reportable) { 'foo' }

    it_reports "foo\n"
  end

  describe '.delegate' do
    let(:reportable) { double(foo: :bar, baz: :boz) }

    let(:class_under_test) do
      Class.new(described_class) do
        delegate :foo, :baz

        def run
          puts(foo)
          puts(baz)
        end
      end
    end

    it_reports "bar\nboz\n"

    it 'sets delegation methods to private visibility' do
      expect(class_under_test.private_instance_methods).to include(:foo, :baz)
    end
  end

  describe '#status' do
    let(:class_under_test) do
      Class.new(described_class) do
        def run
          status('foo %s', 'bar')
        end
      end
    end

    context 'on tty' do
      context 'on success' do
        it_reports Mutant::Color::GREEN.format('foo bar') << "\n"
      end

      context 'on failure' do
        let(:success?) { false }
        it_reports Mutant::Color::RED.format('foo bar') << "\n"
      end
    end

    context 'on no tty' do
      let(:tty?) { false }

      context 'on success' do
        it_reports "foo bar\n"
      end

      context 'on failure' do
        let(:success?) { false }

        it_reports "foo bar\n"
      end
    end
  end

  describe '#visit_collection' do
    let(:class_under_test) do
      reporter = nested_reporter
      Class.new(described_class) do
        define_method(:run) do
          visit_collection(reporter, %w[foo bar])
        end
      end
    end

    let(:nested_reporter) do
      Class.new(described_class) do
        def run
          puts object
        end
      end
    end

    it_reports "foo\nbar\n"
  end

  describe '#visit' do
    let(:class_under_test) do
      reporter = nested_reporter
      Class.new(described_class) do
        define_method(:run) do
          visit(reporter, 'foo')
        end
      end
    end

    let(:nested_reporter) do
      Class.new(described_class) do
        def run
          puts object
        end
      end
    end

    it_reports "foo\n"
  end

  describe '#info' do
    let(:class_under_test) do
      Class.new(described_class) do
        def run
          info('%s - %s', 'foo', 'bar')
        end
      end
    end

    it_reports "foo - bar\n"
  end

  describe '#colorize' do
    let(:class_under_test) do
      Class.new(described_class) do
        def run
          puts(colorize(Mutant::Color::RED, 'foo'))
        end
      end
    end

    context 'when output is a tty?' do
      it_reports Mutant::Color::RED.format('foo') << "\n"
    end

    context 'when output is NOT a tty?' do
      let(:tty?) { false }
      it_reports "foo\n"
    end
  end
end
