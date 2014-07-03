require 'spec_helper'

describe Mutant::Subject, '#mutations' do
  subject { object.mutations }

  let(:class_under_test) do
    mutation_a, mutation_b = self.mutation_a, self.mutation_b
    Class.new(described_class) do
      define_method(:generate_mutations) do |emitter|
        emitter << mutation_a
        emitter << mutation_b
      end
    end
  end

  let(:object)     { class_under_test.new(config, context, node) }
  let(:config)     { Mutant::Config::DEFAULT                     }
  let(:node)       { double('Node')                              }
  let(:context)    { double('Context')                           }
  let(:mutation_a) { double('Mutation A')                        }
  let(:mutation_b) { double('Mutation B')                        }

  it { should eql([mutation_a, mutation_b]) }
end
