# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Methods::Instance, '#call' do
  let(:object) { described_class.new(class_under_test) }

  let(:env) do
    config = Fixtures::TEST_ENV.config

    Fixtures::TEST_ENV.with(config: config.with(reporter: capture_reporter))
  end

  let(:capture_reporter) do
    Class.new(Mutant::Reporter::Null) do
      attr_reader :warnings

      def initialize
        @warnings = []
      end

      def warn(message)
        @warnings << message
      end
    end.new
  end

  context 'on regular case' do
    let(:class_under_test) do
      parent = Module.new do
        def method_d; end

        def method_e; end
      end

      Class.new do
        include parent

        private :method_d

        def method_a; end

      protected

        def method_b; end

      private

        def method_c; end
      end
    end

    let(:subject_a) { instance_double(Mutant::Subject)  }
    let(:subject_b) { instance_double(Mutant::Subject)  }
    let(:subject_c) { instance_double(Mutant::Subject)  }
    let(:subjects)  { [subject_a, subject_b, subject_c] }

    before do
      {
        method_a: subject_a,
        method_b: subject_b,
        method_c: subject_c
      }.each do |method, subject|
        matcher = instance_double(Mutant::Matcher)
        expect(matcher).to receive(:call).with(env).and_return([subject])

        expect(Mutant::Matcher::Method::Instance).to receive(:new)
          .with(class_under_test, class_under_test.instance_method(method))
          .and_return(matcher)
      end
    end

    it 'returns expected subjects' do
      expect(object.call(env)).to eql(subjects)
    end
  end

  context 'on degenerate object interface' do
    let(:object) { described_class.new(scope) }

    let(:scope) do
      Class.new do
        def self.public_instance_methods
          %i[foo]
        end
      end
    end

    def apply
      object.call(env)
    end

    it 'returns empty matches' do
      expect(apply).to eql([])
    end

    it 'warns about degnerate interfacew' do
      apply

      exception =
        begin
          scope.instance_method(:foo)
        rescue NameError => exception
          exception
        end

      expect(capture_reporter.warnings).to eql([<<~'MESSAGE' % { scope: scope, exception: exception }])
        Caught an exception while accessing a method with
        #instance_method that is part of #{public,privat,protected}_instance_methods.

        This is a bug in your ruby implementation its stdlib, libaries our your code.

        Mutant will ignore this method:

        Object:    %<scope>s
        Method:    foo
        Exception: %<exception>s

        See: https://github.com/mbj/mutant/issues/1273
      MESSAGE
    end
  end
end
