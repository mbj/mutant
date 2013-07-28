# encoding: utf-8

require 'spec_helper'

describe Mutant::CLI::Classifier::Scope, '#each' do
  let(:object) { described_class.build(cache, input) }
  let(:cache)  { Mutant::Cache.new                   }
  let(:input)  { ::TestApp::Literal                  }

  context 'with a block' do
    subject { object.each {} }

    it_behaves_like 'a command method'

    it 'yield method subjects' do
      expect { |block| object.each(&block) }
        .to yield_control.exactly(7).times
    end
  end

  context 'without a block' do
   subject { object.each }

    it 'returns an enumerator' do
      should be_instance_of(to_enum.class)
    end

    it 'yield an instance subject' do
      expect { |block| object.each(&block) }
        .to yield_control.exactly(7).times
    end
  end
end
