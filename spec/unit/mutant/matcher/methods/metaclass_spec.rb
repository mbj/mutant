# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Methods::Metaclass, '#call' do
  let(:object) { described_class.new(class_under_test) }
  let(:env)    { Fixtures::TEST_ENV                    }

  let(:class_under_test) do
    parent = Module.new do
      class << self
        def method_d; end

        protected

        def method_e; end

        private

        def method_f; end
      end
    end

    Class.new do
      extend parent

      class << self
        def method_a; end

        protected

        def method_b; end

        private

        def method_c; end
      end
    end
  end

  let(:subject_a) { instance_double(Mutant::Subject, 'A') }
  let(:subject_b) { instance_double(Mutant::Subject, 'B') }
  let(:subject_c) { instance_double(Mutant::Subject, 'C') }

  let(:subjects) { [subject_a, subject_b, subject_c] }

  before do
    matcher = Mutant::Matcher::Method::Metaclass

    {
      method_a: subject_a,
      method_b: subject_b,
      method_c: subject_c
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
