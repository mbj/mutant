require 'spec_helper'

RSpec.describe TestApp::Literal do

  describe '#command' do
    subject { object.command(double) }

    let(:object) { described_class.new }

    it { is_expected.to be(object) }
  end

  describe '#string' do
    subject { object.string }

    let(:object) { described_class.new }

    it { is_expected.to eql('string') }
  end
end
