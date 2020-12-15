# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example::DSL do
  describe '.call' do
    subject { described_class.call(location, types, block) }

    let(:expected) { []                                           }
    let(:location) { instance_double(Thread::Backtrace::Location) }
    let(:lvars)    { []                                           }
    let(:node)     { s(:false)                                    }
    let(:types)    { Set.new([node.type])                         }

    let(:expected_example) do
      Mutant::Meta::Example.new(
        expected:        expected,
        location:        location,
        lvars:           lvars,
        node:            node,
        original_source: source,
        types:           types
      )
    end

    def self.expect_example(&block)
      let(:block) { block }

      specify do
        # Kill mutations to warnings
        warnings = Mutant::WORLD.warnings.call do
          should eql(expected_example)
        end
        expect(warnings).to eql([])
      end
    end

    def self.expect_error(message, &block)
      let(:block) { block }

      specify do
        expect { subject }.to raise_error(RuntimeError, message)
      end
    end

    context 'source as string' do
      let(:source) { 'false' }

      expect_example do
        source 'false'
      end
    end

    context 'using #declare lvar' do
      let(:lvars)  { %i[a]        }
      let(:node)   { s(:lvar, :a) }
      let(:source) { 'a'          }

      expect_example do
        declare_lvar :a

        source 'a'
      end
    end

    context 'using #mutation' do
      let(:source) { 'false' }

      let(:expected) do
        [
          Mutant::Meta::Example::Expected.new(
            node:            s(:nil),
            original_source: 'nil'
          )
        ]
      end

      expect_example do
        source 'false'

        mutation 'nil'
      end
    end

    context 'using #singleton_mutations' do
      let(:source) { 'false' }

      let(:expected) do
        [
          Mutant::Meta::Example::Expected.new(
            node:            s(:nil),
            original_source: 'nil'
          ),
          Mutant::Meta::Example::Expected.new(
            node:            s(:self),
            original_source: 'self'
          )
        ]
      end

      expect_example do
        source 'false'

        singleton_mutations
      end
    end

    context 'using #regexp_mutations' do
      let(:source) { '/foo/' }

      let(:node) do
        s(:regexp, s(:str, 'foo'), s(:regopt))
      end

      let(:expected) do
        [
          Mutant::Meta::Example::Expected.new(
            node:            s(:regexp, s(:regopt)),
            original_source: '//'
          ),
          Mutant::Meta::Example::Expected.new(
            node:            s(:regexp, s(:str, 'nomatch\\A'), s(:regopt)),
            original_source: '/nomatch\\A/'
          )
        ]
      end

      expect_example do
        source '/foo/'

        regexp_mutations
      end
    end

    context 'no definition of source' do
      expect_error('source not defined') do
      end
    end

    context 'duplicate definition of source' do
      expect_error('source already defined') do
        source 'true'
        source 'false'
      end
    end

    context 'uncoercable source' do
      expect_error('Unsupported input: nil') do
        source nil
      end
    end

    context 'duplicate mutation expectation' do
      expect_error('Mutation for input: "true" is already expected') do
        source 'false'

        mutation 'true'
        mutation 'true'
      end
    end
  end
end
