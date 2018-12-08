# frozen_string_literal: true

RSpec.describe Mutant::Result::Mutation do
  let(:object) do
    described_class.new(
      isolation_result: isolation_result,
      mutation:         mutation,
      runtime:          2.0
    )
  end

  let(:mutation) { instance_double(Mutant::Mutation) }

  let(:test_result) do
    instance_double(
      Mutant::Result::Test,
      runtime: 1.0
    )
  end

  let(:isolation_result) do
    Mutant::Isolation::Result::Success.new(test_result)
  end

  shared_examples_for 'unsuccessful isolation' do
    let(:isolation_result) do
      Mutant::Isolation::Result::Exception.new(RuntimeError.new('foo'))
    end
  end

  describe '#killtime' do
    subject { object.killtime }

    context 'if isolation is successful' do
      it { should eql(1.0) }
    end

    context 'if isolation is not successful' do
      include_context 'unsuccessful isolation'

      it { should eql(0.0) }
    end
  end

  describe '#runtime' do
    subject { object.runtime }

    it { should eql(2.0) }
  end

  describe '#success?' do
    subject { object.success? }

    context 'if isolation is successful' do
      before do
        expect(mutation.class).to receive(:success?)
          .with(test_result)
          .and_return(true)
      end

      it { should be(true) }
    end

    context 'if isolation is not successful' do
      include_context 'unsuccessful isolation'

      it { should be(false) }
    end
  end
end
