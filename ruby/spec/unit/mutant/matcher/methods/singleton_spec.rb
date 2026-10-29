# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Methods::Singleton, '#call' do
  let(:object) { described_class.new(scope:) }
  let(:env)    { Fixtures::TEST_ENV }

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

    end
  end

  let(:subject_a) { instance_double(Mutant::Subject, 'A') }
  let(:subject_b) { instance_double(Mutant::Subject, 'B') }
  let(:subject_c) { instance_double(Mutant::Subject, 'C') }

  let(:subjects) { [subject_a, subject_b, subject_c] }

  let(:scope) do
    Mutant::Scope.new(
      expression: instance_double(Mutant::Expression),
      raw:        class_under_test
    )
  end

  before do
    matcher = Mutant::Matcher::Method::Singleton

    {
      method_a: subject_a,
      method_b: subject_b,
      method_c: subject_c
    }.each do |method, subject|
      allow(matcher).to receive(:new)
        .with(scope:, target_method: class_under_test.method(method))
        .and_return(Mutant::Matcher::Static.new(subjects: [subject]))
    end
  end

  it 'returns expected subjects' do
    expect(object.call(env)).to eql(subjects)
  end
end

RSpec.describe Mutant::Matcher::Methods::Singleton, '#call with a prepended wrapper' do
  let(:object) { described_class.new(scope:) }
  let(:env)    { Fixtures::TEST_ENV }
  let(:subject_a) { instance_double(Mutant::Subject, 'A') }

  let(:class_under_test) do
    wrapper = Module.new do
      def wrapped_method; end
    end

    Class.new do
      def self.wrapped_method; end

      singleton_class.prepend(wrapper)
    end
  end

  let(:scope) do
    Mutant::Scope.new(
      expression: instance_double(Mutant::Expression),
      raw:        class_under_test
    )
  end

  before do
    expect(Mutant::Matcher::Method::Singleton).to receive(:new)
      .with(scope:, target_method: class_under_test.method(:wrapped_method).super_method)
      .and_return(Mutant::Matcher::Static.new(subjects: [subject_a]))
  end

  it 'returns the subject defined on the scope' do
    expect(object.call(env)).to eql([subject_a])
  end
end
