require 'spec_helper'

describe TestApp::Literal, '#string' do
  subject { object.command(double) }

  let(:object) { described_class.new }

  it_should_behave_like 'a command method'
end
