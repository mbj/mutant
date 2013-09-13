# encoding: utf-8

require 'spec_helper'

describe Mutant::CLI::Classifier::Method, '#each' do

  let(:object)           { described_class.run(cache, input) }
  let(:cache)            { Mutant::Cache.new                   }
  let(:instance_method)  { '::TestApp::Literal#string'         }
  let(:singleton_method) { '::TestApp::Literal.string'         }
  let(:unknown_method)   { '::TestApp::Literal#unknown'        }

  context 'with a block' do
    subject { object.each {} }

    context 'with an instance method name' do
      let(:input) { instance_method }

      it_behaves_like 'a command method'

      it 'yield an instance subject' do
        expect { |block| object.each(&block) }
          .to yield_with_args(Mutant::Subject::Method::Instance)
      end
    end

    context 'with an singleton method name' do
      let(:input) { singleton_method }

      it_behaves_like 'a command method'

      it 'yield an instance subject' do
        expect { |block| object.each(&block) }
          .to yield_with_args(Mutant::Subject::Method::Singleton)
      end
    end

    context 'with an unknown method' do
      let(:input) { unknown_method }

      it 'raises an exception' do
        expect { subject }
          .to raise_error(NameError, "Cannot find method #{input}")
      end
    end
  end

  context 'without a block' do
    subject { object.each }

    context 'with an instance method name' do
      let(:input) { instance_method }

      it 'returns an enumerator' do
        should be_instance_of(to_enum.class)
      end

      it 'yield an instance subject' do
        expect { |block| subject.each(&block) }
          .to yield_with_args(Mutant::Subject::Method::Instance)
      end
    end

    context 'with an singleton method name' do
      let(:input) { singleton_method }

      it 'returns an enumerator' do
        should be_instance_of(to_enum.class)
      end

      it 'yield an instance subject' do
        expect { |block| subject.each(&block) }
          .to yield_with_args(Mutant::Subject::Method::Singleton)
      end
    end
  end
end
