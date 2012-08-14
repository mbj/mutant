require 'spec_helper'

describe Mutant::Killer::Rspec,'#error_stream' do
  subject { object.error_stream }

  let(:object)           { described_class.run(mutation_subject,mutant)  }
  let(:mutation_subject) { mock('Subject', :insert => nil,:reset => nil) }
  let(:mutant)           { mock('Mutant')                                }

  before do
    RSpec::Core::Runner.stub(:run => 1)
  end

  it_should_behave_like 'an idempotent method'

  it { should be_kind_of(StringIO) }

  its(:read) { should eql('') }
end
