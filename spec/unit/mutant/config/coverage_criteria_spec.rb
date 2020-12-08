# frozen_string_literal: true

RSpec.describe Mutant::Config::CoverageCriteria do
  describe '#merge' do
    let(:original) do
      described_class.new(
        test_result:   test_result,
        timeout:       timeout,
        process_abort: process_abort
      )
    end

    let(:test_result)   { nil }
    let(:timeout)       { nil }
    let(:process_abort) { nil }

    def apply
      original.merge(other)
    end

    %i[test_result timeout process_abort].each do |key|
      context "for #{key} attributze" do
        context 'when original is not nil' do
          let(key) { true }

          context 'and other is nil' do
            let(:other) { original.with(key => nil) }

            it 'returns original value' do
              expect(apply.public_send(key)).to be(true)
            end
          end

          context 'and other is not nil' do
            let(:other) { original.with(key => false) }

            it 'returns original value' do
              expect(apply.public_send(key)).to be(false)
            end
          end
        end

        context 'when original is nil' do
          let(key) { nil }

          let(:other) { original.with(key => false) }

          it 'returns other value' do
            expect(apply.public_send(key)).to be(false)
          end
        end
      end
    end
  end
end
