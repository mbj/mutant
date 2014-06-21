require 'spec_helper'

describe Mutant::Diff do
  let(:object) { described_class }

  describe '.build' do

    subject { object.build(old_string, new_string) }

    let(:old_string) { "foo\nbar" }
    let(:new_string) { "bar\nbaz" }

    it { should eql(Mutant::Diff.new(%w[foo bar], %w[bar baz])) }

  end

  describe '.colorize_line' do
    let(:object) { described_class }

    subject { object.colorize_line(line) }

    context 'line beginning with "+"' do
      let(:line) { '+line' }

      it { should eql(Mutant::Color::GREEN.format(line)) }
    end

    context 'line beginning with "-"' do
      let(:line) { '-line' }

      it { should eql(Mutant::Color::RED.format(line)) }
    end

    context 'line beginning in other char' do
      let(:line) { ' line' }

      it { should eql(line) }
    end
  end

  describe '#diff' do
    let(:object) { described_class.new(old, new) }

    subject { object.diff }

    context 'when there is a diff at begin of hunk' do
      let(:old) { %w[foo bar] }
      let(:new) { %w[baz bar] }

      let(:expectation) do
        strip_indent(<<-STR)
          @@ -1,3 +1,3 @@
          -foo
          +baz
           bar
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when there is a diff NOT at begin of hunk' do
      let(:old) { %w[foo bar]     }
      let(:new) { %w[foo baz bar] }

      let(:expectation) do
        strip_indent(<<-STR)
          @@ -1,3 +1,4 @@
           foo
          +baz
           bar
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when the diff has a long context at begin' do
      let(:old) { %w[foo bar baz boz a b c]       }
      let(:new) { %w[foo bar baz boz a b c other] }

      let(:expectation) do
        strip_indent(<<-STR)
          @@ -1,8 +1,9 @@
           foo
           bar
           baz
           boz
           a
           b
           c
          +other
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when the diff has a long context at end, deleting' do
      let(:old) { %w[other foo bar baz boz a b c] }
      let(:new) { %w[foo bar baz boz a b c]       }

      let(:expectation) do
        strip_indent(<<-STR)
          @@ -1,9 +1,8 @@
          -other
           foo
           bar
           baz
           boz
           a
           b
           c
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when the diff has a long context at end, inserting' do
      let(:old) { %w[foo bar baz boz a b c]       }
      let(:new) { %w[other foo bar baz boz a b c] }

      let(:expectation) do
        strip_indent(<<-STR)
          @@ -1,8 +1,9 @@
          +other
           foo
           bar
           baz
           boz
           a
           b
           c
        STR
      end

      it { should eql(expectation) }

      it_should_behave_like 'an idempotent method'
    end

    context 'when there is no diff' do
      let(:old) { '' }
      let(:new) { '' }

      it { should be(nil) }

      it_should_behave_like 'an idempotent method'
    end
  end
end
