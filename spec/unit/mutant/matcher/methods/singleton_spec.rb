RSpec.describe Mutant::Matcher::Methods::Singleton, '#each' do
  let(:object) { described_class.new(env, class_under_test) }
  let(:env)    { Fixtures::TEST_ENV            }

  subject { object.each { |matcher| yields << matcher } }

  let(:yields) { [] }

  let(:class_under_test) do
    parent = Module.new do
      def method_d
      end

      def method_e
      end
    end

    Class.new do
      extend parent

      def self.method_a
      end

      def self.method_b
      end
      class << self; protected :method_b; end

      def self.method_c
      end
      private_class_method :method_c

    end
  end

  let(:subject_a) { double('Subject A') }
  let(:subject_b) { double('Subject B') }
  let(:subject_c) { double('Subject C') }

  let(:subjects) { [subject_a, subject_b, subject_c] }

  before do
    matcher = Mutant::Matcher::Method::Singleton
    allow(matcher).to receive(:new)
      .with(env, class_under_test, class_under_test.method(:method_a)).and_return([subject_a])
    allow(matcher).to receive(:new)
      .with(env, class_under_test, class_under_test.method(:method_b)).and_return([subject_b])
    allow(matcher).to receive(:new)
      .with(env, class_under_test, class_under_test.method(:method_c)).and_return([subject_c])
  end

  it 'should yield expected subjects' do
    subject
    expect(yields).to eql(subjects)
  end

  it_should_behave_like 'an #each method'
end
