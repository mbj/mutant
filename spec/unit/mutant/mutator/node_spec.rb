require 'spec_helper'

describe Mutant::Mutator::Node do
  Mutant::Meta::Example::ALL.each do |example|
    context "on #{example.node.type.inspect}" do
      it 'generates the correct mutations' do
        verification = example.verification
        unless verification.success?
          fail verification.error_report
        end
      end
    end
  end
end
