# encoding: utf-8

require 'spec_helper'

RSpec.describe TestApp::Literal, '#string' do
  subject { object.command(double) }

  let(:object) { described_class.new }

  it { should be(object) }
end
