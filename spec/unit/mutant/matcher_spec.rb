# frozen_string_literal: true

RSpec.describe Mutant::Matcher do
  describe '.expand' do
    def apply
      described_class.expand(env: env)
    end

    let(:anon_matcher)       { instance_double(Mutant::Matcher)    }
    let(:diffs)              { []                                  }
    let(:expression_a)       { expression('Foo::Bar#a', matcher_a) }
    let(:expression_b)       { expression('Foo::Bar#b', matcher_b) }
    let(:ignore_expressions) { []                                  }

    let(:env) do
      instance_double(
        Mutant::Env,
        config: instance_double(Mutant::Config, matcher: config)
      )
    end

    let(:matcher_a) do
      instance_double(Mutant::Matcher, call: [subject_a])
    end

    let(:matcher_b) do
      instance_double(Mutant::Matcher, call: [subject_b])
    end

    let(:expression_class) do
      Class.new(Mutant::Expression) do
        include Unparser::Anima.new(:child, :matcher)
        include Unparser::Equalizer.new

        %w[syntax prefix?].each do |name|
          define_method(name) do |*arguments, &block|
            child.public_send(name, *arguments, &block)
          end
        end

        define_method(:matcher) do |env:|
          fail unless env
          @matcher
        end
      end
    end

    let(:config) do
      Mutant::Matcher::Config.new(
        ignore:            ignore_expressions,
        subjects:          [expression_a, expression_b],
        start_expressions: [],
        diffs:             diffs
      )
    end

    let(:subject_a) do
      instance_double(
        Mutant::Subject,
        'subject a',
        expression:       expression('Foo::Bar#a'),
        inline_disabled?: false,
        source_lines:     1..10,
        source_path:      'subject/a.rb'
      )
    end

    let(:subject_b) do
      instance_double(
        Mutant::Subject,
        'subject b',
        expression:       expression('Foo::Bar#b'),
        inline_disabled?: false,
        source_lines:     100..101,
        source_path:      'subject/b.rb'
      )
    end

    def expression(input, matcher = anon_matcher)
      expression_class.new(child: parse_expression(input), matcher: matcher)
    end

    context 'no restrictions of any kinds' do
      it 'returns expected subjects' do
        expect(apply.call(env)).to eql([subject_a, subject_b])
      end
    end

    context 'with explicit disable' do
      before do
        allow(subject_b).to receive_messages(inline_disabled?: true)
      end

      it 'returns expected subjects' do
        expect(apply.call(env)).to eql([subject_a])
      end
    end

    context 'with ignore matching a subject' do
      let(:ignore_expressions) { [subject_b.expression] }

      it 'returns expected subjects' do
        expect(apply.call(env)).to eql([subject_a])
      end
    end

    context 'with ignore matching many subjects' do
      let(:ignore_expressions) { [expression('Foo*')] }

      it 'returns expected subjects' do
        expect(apply.call(env)).to eql([])
      end
    end

    context 'with diffs' do
      let(:diff_a) { instance_double(Mutant::Repository::Diff) }
      let(:diff_b) { instance_double(Mutant::Repository::Diff) }

      let(:subject_a_touches_diff_a?) { false }
      let(:subject_b_touches_diff_a?) { false }
      let(:subject_a_touches_diff_b?) { false }
      let(:subject_b_touches_diff_b?) { false }

      before do
        allow(diff_a).to receive(:touches?)
          .with(subject_a.source_path, subject_a.source_lines)
          .and_return(subject_a_touches_diff_a?)

        allow(diff_a).to receive(:touches?)
          .with(subject_b.source_path, subject_b.source_lines)
          .and_return(subject_b_touches_diff_a?)

        allow(diff_b).to receive(:touches?)
          .with(subject_a.source_path, subject_a.source_lines)
          .and_return(subject_a_touches_diff_b?)

        allow(diff_b).to receive(:touches?)
          .with(subject_b.source_path, subject_b.source_lines)
          .and_return(subject_b_touches_diff_b?)
      end

      context 'with one diff' do
        let(:diffs) { [diff_a] }

        context 'when its touched by subject a' do
          let(:subject_a_touches_diff_a?) { true }

          it 'returns expected subjects' do
            expect(apply.call(env)).to eql([subject_a])
          end
        end
      end

      context 'with two diffs' do
        let(:diffs) { [diff_a, diff_b] }

        context 'when one is touched by subject a' do
          let(:subject_a_touches_diff_b?) { true }

          it 'returns expected subjects' do
            expect(apply.call(env)).to eql([])
          end
        end

        context 'when both are touched by subject a' do
          let(:subject_a_touches_diff_a?) { true }
          let(:subject_a_touches_diff_b?) { true }

          it 'returns expected subjects' do
            expect(apply.call(env)).to eql([subject_a])
          end
        end
      end
    end
  end
end
