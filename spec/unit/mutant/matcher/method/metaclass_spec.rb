# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Methods::Metaclass, '#call' do
  let(:object) { described_class.new(class_under_test) }
  let(:env)    { Fixtures::TEST_ENV                    }

  let(:class_under_test) do
    parent = Module.new do
      def method_d; end

      def method_e; end
    end

    Class.new do
      extend parent

      class << self
        def method_f; end

        protected

        def method_g; end

        private

        def method_h; end
      end
    end
  end

  let(:subject_f) { instance_double(Mutant::Subject, 'F') }
  let(:subject_g) { instance_double(Mutant::Subject, 'G') }
  let(:subject_h) { instance_double(Mutant::Subject, 'H') }

  let(:subjects) { [subject_f, subject_g, subject_h] }

  before do
    matcher = Mutant::Matcher::Method::Metaclass

    {
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
