# encoding: utf-8

require 'spec_helper'

describe Mutant::CLI::Classifier::Namespace::Recursive, '#each' do
  let(:object)            { described_class.run(cache, "#{input}*") }
  let(:cache)             { Mutant::Cache.new                         }
  let(:known_namespace)   { '::TestApp::Literal'                      }
  let(:unknown_namespace) { '::TestApp::Object'                       }

  context 'with a block' do
    subject { object.each { } }

    context 'with a known namespace' do
      let(:input) { known_namespace }

      it_behaves_like 'a command method'

      it 'yield method subjects' do
        expect { |block| object.each(&block) }
          .to yield_control.exactly(7).times
      end
    end

    context 'with an unknown namespace' do
      let(:input) { unknown_namespace }

      it 'raises an exception' do
        expect { subject }.to raise_error(NameError)
      end
    end
  end

  context 'without a block' do
    subject { object.each }

    context 'with a known namespace' do
      let(:input) { known_namespace }

      it 'returns an enumerator' do
        should be_instance_of(to_enum.class)
      end

      it 'yield an instance subject' do
        expect { |block| object.each(&block) }
          .to yield_control.exactly(7).times
      end
    end

    context 'with an unknown namespace' do
      let(:input) { unknown_namespace }

      it 'raises an exception when #each is called' do
        expect { subject.each { } }.to raise_error(NameError)
      end
    end
  end
end
