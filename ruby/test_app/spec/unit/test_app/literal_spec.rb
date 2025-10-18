require 'spec_helper'

RSpec.describe TestApp::Literal do

  describe '#command' do
    subject { object.command(double) }

    let(:object) { described_class.new }

    it { should be(object) }
  end

  describe '#string' do
    subject { object.string }

    let(:object) { described_class.new }

    it { should eql('string') }
  end
end
