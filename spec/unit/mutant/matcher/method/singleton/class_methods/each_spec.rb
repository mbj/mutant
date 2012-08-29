require 'spec_helper'

describe Mutant::Matcher::Method::Singleton, '.each' do
  subject { object.each(scope) { |item| yields << item } }

  let(:each_arguments) { [scope] }

  let(:object)   { described_class }
  let(:yields)   { []              }

  context 'when scope is a Class' do
    let(:scope) do
      ancestor = Class.new do
        def self.ancestor_method
        end

        def self.name; 'SomeRandomClass'; end
      end

      Class.new(ancestor) do
        def self.public_method; end
        public_class_method :public_method

        class << self
          def protected_method; end

          protected :protected_method
        end

        def self.private_method; end
        private_class_method :private_method
      end
    end

    it 'should yield instance method matchers' do
      expected = [
        Mutant::Matcher::Method::Singleton.new(scope, :public_method   ),
        Mutant::Matcher::Method::Singleton.new(scope, :protected_method),
        Mutant::Matcher::Method::Singleton.new(scope, :private_method  )
      ].sort_by(&:method_name)

      expect { subject }.to change { yields.dup }.from([]).to(expected)
    end
  end
end
