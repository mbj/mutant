# frozen_string_literal: true

RSpec.describe Mutant::Selector::ContextMap do
  let(:object) { described_class.new(context_map:, fallback:, integration:) }

  let(:root)   { '/project' }
  let(:source) { '/project/lib/subject.rb' }

  let(:test_a) { mk_test('spec/a_spec.rb:10')  }
  let(:test_b) { mk_test('spec/b_spec.rb:20')  }
  let(:test_c) { mk_test(nil)                  }

  let(:available_tests) { [test_a, test_b, test_c] }

  let(:fallback_tests) { [test_c] }

  let(:fallback) do
    instance_double(Mutant::Selector).tap do |selector|
      allow(selector).to receive(:call).with(mutation_subject).and_return(fallback_tests)
    end
  end

  let(:integration) do
    instance_double(Mutant::Integration, available_tests:)
  end

  let(:mutation_subject) do
    instance_double(
      Mutant::Subject,
      match_expressions: [parse_expression('Widget#padding')],
      source_path:       Pathname.new(source),
      source_lines:      3..4
    )
  end

  let(:context_map) do
    Mutant::ContextMap.new(
      root:,
      tables: {
        source => {
          # line 3
          '/project/spec/a_spec.rb:10' => 0b100,
          # line 9
          '/project/spec/b_spec.rb:20' => 0b100000000
        }
      }
    )
  end

  def mk_test(location, id = location.to_s, expressions = [])
    Mutant::Test.new(expressions:, id:, location:)
  end

  describe '#name' do
    it 'returns the strategy name' do
      expect(object.name).to eql('context_map')
    end
  end

  describe '#call' do
    def apply
      object.call(mutation_subject)
    end

    context 'with tests covering the subject' do
      it 'returns them' do
        expect(apply).to eql([test_a])
      end
    end

    context 'with tests covering every subject line' do
      let(:mutation_subject) { super().tap { |double| allow(double).to receive(:source_lines).and_return(3..9) } }

      it 'returns all of them' do
        expect(apply).to eql([test_a, test_b])
      end
    end

    context 'with several tests recorded at one location' do
      let(:test_d)          { mk_test('spec/a_spec.rb:10', 'd') }
      let(:available_tests) { [test_a, test_b, test_c, test_d] }

      it 'returns each of them' do
        expect(apply).to eql([test_d, test_a])
      end
    end

    context 'with a recorded test this suite does not run' do
      let(:available_tests) { [test_a, test_c] }

      let(:mutation_subject) do
        super().tap { |double| allow(double).to receive(:source_lines).and_return(3..9) }
      end

      it 'returns only the tests it has' do
        expect(apply).to eql([test_a])
      end
    end

    context 'without tests covering the subject' do
      let(:mutation_subject) { super().tap { |double| allow(double).to receive(:source_lines).and_return(1..2) } }

      it 'falls back' do
        expect(apply).to eql(fallback_tests)
      end
    end

    context 'with several covering tests' do
      let(:mutation_subject) do
        super().tap { |double| allow(double).to receive(:source_lines).and_return(3..6) }
      end

      # Every test below executes line 3, so nothing but the ranking separates
      # them. Bit 2 is line 3, bits 3 and 4 are lines 4 and 5.
      let(:context_map) do
        Mutant::ContextMap.new(
          root:,
          tables: {
            source                  => {
              '/project/spec/broad_spec.rb:1'   => 0b11100,
              '/project/spec/focused_spec.rb:1' => 0b00100,
              '/project/spec/named_spec.rb:1'   => 0b00100
            },
            '/project/lib/other.rb' => {
              '/project/spec/broad_spec.rb:1'   => 0b1111111111,
              '/project/spec/focused_spec.rb:1' => 0b1,
              '/project/spec/named_spec.rb:1'   => 0b11111111111111111111
            }
          }
        )
      end

      let(:broad)   { mk_test('spec/broad_spec.rb:1')   }
      let(:focused) { mk_test('spec/focused_spec.rb:1') }
      let(:named)   { mk_test('spec/named_spec.rb:1')   }

      let(:available_tests) { [broad, focused, named] }

      it 'puts the most focused test first' do
        expect(apply).to eql([focused, broad, named])
      end

      context 'with a test the expressions also name' do
        let(:named) do
          mk_test('spec/named_spec.rb:1', 'named', [parse_expression('Widget#padding')])
        end

        it 'puts that test first' do
          expect(apply).to eql([named, focused, broad])
        end
      end

      context 'with several tests the expressions name' do
        let(:broad) do
          mk_test('spec/broad_spec.rb:1', 'broad', [parse_expression('Widget#padding')])
        end

        let(:focused) do
          mk_test('spec/focused_spec.rb:1', 'focused', [parse_expression('Widget#padding')])
        end

        it 'ranks them among themselves' do
          expect(apply).to eql([focused, broad, named])
        end
      end

      context 'with a subject matching under several expressions' do
        let(:mutation_subject) do
          super().tap do |double|
            allow(double).to receive(:match_expressions)
              .and_return([parse_expression('Widget#width'), parse_expression('Widget#padding')])
          end
        end

        let(:named) do
          mk_test('spec/named_spec.rb:1', 'named', [parse_expression('Widget#padding')])
        end

        it 'puts a test matching any of them first' do
          expect(apply).to eql([named, focused, broad])
        end
      end

      context 'with fully tied tests' do
        let(:context_map) do
          Mutant::ContextMap.new(
            root:,
            tables: {
              source => {
                '/project/spec/focused_spec.rb:1' => 0b100,
                '/project/spec/broad_spec.rb:1'   => 0b100
              }
            }
          )
        end

        let(:available_tests) { [focused, broad] }

        it 'orders them by test id' do
          expect(apply).to eql([broad, focused])
        end
      end

      context 'with a test naming another subject' do
        let(:named) do
          mk_test('spec/named_spec.rb:1', 'named', [parse_expression('Widget#width')])
        end

        it 'leaves it ranked by coverage' do
          expect(apply).to eql([focused, broad, named])
        end
      end

      context 'with tests of equal focus' do
        # broad reaches 3 of 4 lines it executed, focused 1 of 2, named 1 of 2.
        let(:context_map) do
          super().with(
            tables: super().tables.merge(
              '/project/lib/other.rb' => {
                '/project/spec/broad_spec.rb:1'   => 0b1,
                '/project/spec/focused_spec.rb:1' => 0b1,
                '/project/spec/named_spec.rb:1'   => 0b1
              }
            )
          )
        end

        it 'puts the test reaching most of the subject first' do
          expect(apply).to eql([broad, focused, named])
        end
      end

      context 'with tests of equal focus and unequal reach' do
        # Both spend half their footprint on the subject, broad on two of its
        # lines and focused on one. The ids sort the other way round, so only
        # reach can produce the expected order.
        let(:broad)   { mk_test('spec/broad_spec.rb:1', 'z-broad')     }
        let(:focused) { mk_test('spec/focused_spec.rb:1', 'a-focused') }

        let(:context_map) do
          Mutant::ContextMap.new(
            root:,
            tables: {
              source                  => {
                '/project/spec/focused_spec.rb:1' => 0b00100,
                '/project/spec/broad_spec.rb:1'   => 0b01100
              },
              '/project/lib/other.rb' => {
                '/project/spec/focused_spec.rb:1' => 0b1,
                '/project/spec/broad_spec.rb:1'   => 0b11
              }
            }
          )
        end

        let(:available_tests) { [focused, broad] }

        it 'puts the test reaching most of the subject first' do
          expect(apply).to eql([broad, focused])
        end
      end
    end

    context 'on a subject the recording does not know' do
      let(:mutation_subject) do
        instance_double(
          Mutant::Subject,
          source_path:  Pathname.new('/project/lib/elsewhere.rb'),
          source_lines: 3..4
        )
      end

      it 'falls back' do
        expect(apply).to eql(fallback_tests)
      end
    end
  end

  describe '#unmatched?' do
    def apply
      object.unmatched?
    end

    context 'with a test the recording names' do
      it { expect(apply).to be(false) }
    end

    context 'without a test the recording names' do
      let(:available_tests) { [mk_test('spec/elsewhere_spec.rb:1')] }

      it { expect(apply).to be(true) }
    end

    context 'with only tests the integration cannot locate' do
      let(:available_tests) { [test_c] }

      it { expect(apply).to be(true) }
    end

    context 'without available tests' do
      let(:available_tests) { [] }

      it { expect(apply).to be(true) }
    end
  end
end
