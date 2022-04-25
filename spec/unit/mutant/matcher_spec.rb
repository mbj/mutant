# frozen_string_literal: true

RSpec.describe Mutant::Matcher do
  describe '.from_config' do
    def apply
      described_class.from_config(config)
    end

    let(:anon_matcher)       { instance_double(Mutant::Matcher)    }
    let(:env)                { instance_double(Mutant::Env)        }
    let(:ignore_expressions) { []                                  }
    let(:expression_a)       { expression('Foo::Bar#a', matcher_a) }
    let(:expression_b)       { expression('Foo::Bar#b', matcher_b) }
    let(:subject_filters)    { []                                  }

    let(:matcher_a) do
      instance_double(Mutant::Matcher, call: [subject_a])
    end

    let(:matcher_b) do
      instance_double(Mutant::Matcher, call: [subject_b])
    end

    let(:expression_class) do
      Class.new(Mutant::Expression) do
        include Unparser::Concord.new(:child, :matcher)

        %w[syntax prefix?].each do |name|
          define_method(name) do |*arguments, &block|
            child.public_send(name, *arguments, &block)
          end
        end

        public :matcher
      end
    end

    let(:config) do
      Mutant::Matcher::Config.new(
        ignore:            ignore_expressions,
        subjects:          [expression_a, expression_b],
        start_expressions: [],
        subject_filters:   subject_filters
      )
    end

    let(:subject_a) do
      instance_double(
        Mutant::Subject,
        'subject a',
        expression:       expression('Foo::Bar#a'),
        inline_disabled?: false
      )
    end

    let(:subject_b) do
      instance_double(
        Mutant::Subject,
        'subject b',
        expression:       expression('Foo::Bar#b'),
        inline_disabled?: false
      )
    end

    def expression(input, matcher = anon_matcher)
      expression_class.new(parse_expression(input), matcher)
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

    context 'with subject filter' do
      let(:subject_filters) do
        [subject_a.public_method(:eql?)]
      end

      it 'returns expected subjects' do
        expect(apply.call(env)).to eql([subject_a])
      end
    end

    context 'with subject ignore and filter' do
      let(:ignore_expressions) { [subject_b.expression] }

      let(:subject_filters) do
        [subject_b.public_method(:eql?)]
      end

      it 'returns expected subjects' do
        expect(apply.call(env)).to eql([])
      end
    end
  end
end
