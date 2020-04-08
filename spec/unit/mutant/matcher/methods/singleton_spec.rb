# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Methods::Singleton, '#call' do
  let(:object) { described_class.new(class_under_test) }
  let(:env)    { Fixtures::TEST_ENV                    }

  let(:class_under_test) do
    parent = Module.new do
      def method_d; end

      def method_e; end
    end

    Class.new do
      extend parent

      def self.method_a; end

      def self.method_b; end
      class << self; protected :method_b; end

      def self.method_c; end
      private_class_method :method_c

      class << self
        def method_f; end

        protected

        def method_g; end

        private

        def method_h; end
      end
    end
  end

  let(:subject_a) { instance_double(Mutant::Subject, 'A') }
  let(:subject_b) { instance_double(Mutant::Subject, 'B') }
  let(:subject_c) { instance_double(Mutant::Subject, 'C') }
  let(:subject_f) { instance_double(Mutant::Subject, 'F') }
  let(:subject_g) { instance_double(Mutant::Subject, 'G') }
  let(:subject_h) { instance_double(Mutant::Subject, 'H') }

  let(:subjects) { [subject_a, subject_b, subject_c] }

  before do
    matcher = Mutant::Matcher::Method::Singleton

    {
      method_a: subject_a,
      method_b: subject_b,
      method_c: subject_c,
      method_f: subject_f,
      method_g: subject_g,
      method_h: subject_h
    }.each do |method, subject|
      allow(matcher).to receive(:new)
        .with(class_under_test, class_under_test.method(method))
        .and_return(Mutant::Matcher::Static.new([subject]))
    end
  end

  it 'returns expected subjects' do
    expect(object.call(env)).to eql(subjects)
  end
end
