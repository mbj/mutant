require 'spec_helper'

describe Mutant::Matcher::Method::Instance, '.build' do
  let(:object) { described_class }

  subject { object.build(cache, scope, method) }

  let(:cache) { double }

  let(:scope) do
    Class.new do
      include Adamantium

      def foo
      end
      memoize :foo

      def bar
      end
    end
  end

  let(:method) do
    scope.instance_method(method_name)
  end

  context 'with adamantium infected scope' do
    context 'with unmemoized method' do
      let(:method_name) { :bar }

      it { should eql(Mutant::Matcher::Method::Instance.new(cache, scope, method)) }
    end

    context 'with memoized method' do
      let(:method_name) { :foo }

      it { should eql(Mutant::Matcher::Method::Instance::Memoized.new(cache, scope, method)) }
    end
  end
end
