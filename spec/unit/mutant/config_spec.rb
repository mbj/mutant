require 'spec_helper'

describe Mutant::Config do
  describe '.load' do
    subject { described_class.load(input) }

    context 'with an input of appropriate type and format' do
      let(:input) do
        Mutant::Config::LOADER.inverse.call(Mutant::Config::DEFAULT)
      end

      it { should eql(Mutant::Config::DEFAULT) }
    end
  end

  describe '.load_file' do
    subject { described_class.load_file(path) }

    let(:contents) { double('Contents') }
    let(:config)   { double('Config')   }
    let(:path)     { double('Path')     }

    before do
      expect(YAML).to receive(:load_file).with(path).and_return(contents)
      expect(described_class).to receive(:load).with(contents).and_return(config)
    end

    it { should be(config) }
  end

  describe '.load_default' do
    subject { described_class.load_default }

    it { should eql(described_class.load_file(Pathname.pwd.join('config/mutant.yml'))) }
  end
end
