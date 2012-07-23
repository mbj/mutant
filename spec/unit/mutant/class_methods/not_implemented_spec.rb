require 'spec_helper'

describe Mutant,'.not_implemented' do
  let(:object) { described_class.new }

  let(:described_class) do
    Class.new do
      def foo
        Mutant.not_implemented(self)
      end

      def self.foo
        Mutant.not_implemented(self)
      end

      def self.name
        'Test'
      end
    end
  end

  context 'on instance method' do
    subject { object.foo }
    it 'should raise error' do
      expect { subject }.to raise_error(NotImplementedError,'Test#foo is not implemented')
    end
  end

  context 'on singleton method' do
    subject { described_class.foo }
    it 'should raise error' do
      expect { subject }.to raise_error(NotImplementedError,'Test.foo is not implemented')
    end
  end
end
