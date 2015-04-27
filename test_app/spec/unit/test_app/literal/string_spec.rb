require 'spec_helper'

RSpec.describe TestApp::Literal, '#string' do
  subject { object.string }

  let(:object) { described_class.new }

  it { should eql('string') }
end
