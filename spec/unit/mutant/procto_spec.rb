# frozen_string_literal: true

RSpec.describe Mutant::Procto do
  let(:klass) do
    Class.new do
      include Mutant::Concord.new(:argument), Mutant::Procto

      def call
        argument
      end
    end
  end

  it 'creates a .call that proxies to #call' do
    argument = +'foo'

    expect(klass.call(argument)).to be(argument)
  end
end
