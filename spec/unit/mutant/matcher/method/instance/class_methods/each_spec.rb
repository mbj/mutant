require 'spec_helper'

describe Mutant::Matcher::Method::Instance, '.each' do
  subject { object.each(scope) { |item| yields << item } }

  let(:object)   { described_class }
  let(:yields)   { []              }

  context 'when scope is a Class' do
    let(:scope) do
      ancestor = Class.new do
        def ancestor_method
        end
      end

      Class.new(ancestor) do
        def self.name; 'SomeRandomClass'; end

        def public_method; end
        public :public_method

        def protected_method; end
        protected :protected_method

        def private_method; end
        private :private_method
      end
    end

    it 'should yield instance method matchers' do
      expected = [
        Mutant::Matcher::Method::Instance.new(scope, :public_method   ),
        Mutant::Matcher::Method::Instance.new(scope, :protected_method),
        Mutant::Matcher::Method::Instance.new(scope, :private_method  )
      ].sort_by(&:method_name)

      expect { subject }.to change { yields.dup }.from([]).to(expected)
    end
  end
end
