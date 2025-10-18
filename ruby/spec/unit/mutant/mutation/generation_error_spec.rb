# frozen_string_literal: true

RSpec.describe Mutant::Mutation::GenerationError do
  subject do
    described_class.new(
      node:                s(:false),
      subject:             mutant_subject,
      unparser_validation:
    )
  end

  let(:mutant_subject) do
    instance_double(
      Mutant::Subject,
      identification: '<identification>',
      node:           s(:true),
      source:         'true'
    )
  end

  let(:unparser_validation) do
    instance_double(
      Unparser::Validation,
      original_source: right('false'),
      report:          '<unparser-validation-report>'
    )
  end

  describe '#report' do
    def apply
      subject.report
    end

    it 'returns expected value' do
      expect(apply).to eql(<<~MESSAGE)
        === Mutation-Generation-Error ===
        This is a mutant internal issue detected by a mutant internal cross check.
        Please report an issue with the details below.

        Subject: <identification>.

        Mutation-Source-Diff:
        @@ -1 +1 @@
        \e[31m-true
        \e[0m\e[32m+false
        \e[0m

        Mutation-Node-Diff:
        @@ -1 +1 @@
        \e[31m-(true)
        \e[0m\e[32m+(false)
        \e[0m

        Unparser-Validation:
        <unparser-validation-report>
      MESSAGE
    end
  end
end
