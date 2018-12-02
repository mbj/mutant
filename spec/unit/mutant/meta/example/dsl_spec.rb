# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example::DSL do
  describe '.call' do
    subject { described_class.call(file, types, block) }

    let(:file)     { 'foo.rb'             }
    let(:node)     { s(:false)            }
    let(:types)    { Set.new([node.type]) }
    let(:expected) { []                   }

    let(:expected_example) do
      Mutant::Meta::Example.new(
        file:     file,
        node:     node,
        types:    types,
        expected: expected
      )
    end

    def self.expect_example(&block)
      let(:block) { block }

      specify do
        # Kill mutations to warnings
        warnings = Mutant::WarningFilter.use do
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

    context 'source as node' do
      expect_example do
        source s(:false)
      end
    end

    context 'source as string' do
      expect_example do
        source 'false'
      end
    end

    context 'on node that needs unparser preprocessing to be normalized' do
      let(:node) { s(:send, s(:float, -1.0), :/, s(:float, 0.0)) }

      expect_example do
        source '(-1.0) / 0.0'
      end
    end

    context 'using #mutation' do
      let(:expected) { [s(:nil)] }

      expect_example do
        source 'false'

        mutation 'nil'
      end
    end

    context 'using #singleton_mutations' do
      let(:expected) { [s(:nil), s(:self)] }

      expect_example do
        source 'false'

        singleton_mutations
      end
    end

    context 'using #regexp_mutations' do
      let(:expected) do
        [s(:regexp, s(:regopt)), s(:regexp, s(:str, 'nomatch\\A'), s(:regopt))]
      end

      let(:node) do
        s(:regexp, s(:str, 'foo'), s(:regopt))
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
      expect_error('Cannot coerce to node: nil') do
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
