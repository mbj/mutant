require 'spec_helper'

describe Mutant::Killer,'#fail?' do
  subject { object.fail? }

  let(:object)           { class_under_test.run(mutation_subject,mutant)  }
  let(:mutation_subject) { mock('Subject', :insert => nil, :reset => nil) }
  let(:mutant)           { mock('Mutant')                                 }

  let(:class_under_test) do
    kill_state = self.kill_state
    Class.new(described_class) do
      define_method :run do
        kill_state
      end
    end
  end

  context 'when mutant was killed' do
    let(:kill_state) { true }
    
    it_should_behave_like 'an idempotent method'

    it { should be(false) }
  end

  context 'when mutant was NOT killed' do
    let(:kill_state) { false }
    
    it_should_behave_like 'an idempotent method'

    it { should be(true) }
  end
end
