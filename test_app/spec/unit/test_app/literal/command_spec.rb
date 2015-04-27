require 'spec_helper'

RSpec.describe TestApp::Literal, '#command' do
  subject { object.command(double) }

  let(:object) { described_class.new }

  it { should be(object) }
end
