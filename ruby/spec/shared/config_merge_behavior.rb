# frozen_string_literal: true

RSpec.shared_examples 'maybe value merge' do
  context 'when original has value' do
    context 'when other does not have value' do
      let(:other_value) { nil }

      it 'sets value to original value' do
        expect_value(original_value)
      end
    end

    context 'when other does have a value' do
      it 'sets value to other value' do
        expect_value(other_value)
      end
    end
  end

  context 'when original does not have value' do
    let(:original_value) { nil }

    context 'when other does not have value' do
      let(:other_value) { nil }

      it 'sets value to nil value' do
        expect_value(nil)
      end
    end

    context 'when other does have a value' do
      it 'sets value to other value' do
        expect_value(other_value)
      end
    end
  end
end
