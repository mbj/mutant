require 'spec_helper'

describe Mutant::Runner do
  let(:object) { described_class.new(env) }

  let(:reporter) { Mutant::Reporter::Trace.new                        }
  let(:config)   { Mutant::Config::DEFAULT.update(reporter: reporter) }
  let(:subjects) { [subject_a, subject_b]                             }

  class Double
    include Concord.new(:name, :attributes)

    def self.new(name, attributes = {})
      super
    end

    def update(attributes)
      self
    end

    def method_missing(name, *arguments)
      super unless attributes.key?(name)
      fail "Arguments provided for #{name}" if arguments.any?
      attributes.fetch(name)
    end
  end

  let(:subject_a) { Double.new('Subject A', mutations: mutations_a, tests: subject_a_tests) }
  let(:subject_b) { Double.new('Subject B', mutations: mutations_b) }

  let(:subject_a_tests) { [test_a1, test_a2] }

  let(:env) do
    subjects = self.subjects
    Class.new(Mutant::Env) do
      define_method(:subjects) { subjects }
    end.new(config)
  end

  let(:mutations_a) { [mutation_a1, mutation_a2] }
  let(:mutations_b) { [] }

  let(:mutation_a1) { Double.new('Mutation A1') }
  let(:mutation_a2) { Double.new('Mutation A2') }

  let(:test_a1) { Double.new('Test A1') }
  let(:test_a2) { Double.new('Test A2') }

  let(:test_report_a1) { Double.new('Test Report A1') }

  before do
    allow(mutation_a1).to receive(:subject).and_return(subject_a)
    allow(mutation_a1).to receive(:insert)
    allow(mutation_a2).to receive(:subject).and_return(subject_a)
    allow(mutation_a2).to receive(:insert)
    allow(test_a1).to receive(:run).and_return(test_report_a1)
    allow(mutation_a1).to receive(:killed_by?).with(test_report_a1).and_return(true)
    allow(mutation_a2).to receive(:killed_by?).with(test_report_a1).and_return(true)
  end

  before do
    time = Time.at(0)
    allow(Time).to receive(:now).and_return(time)
  end

  describe '#result' do
    subject { object.result }

    its(:env)             { should be(env)                       }
    its(:subject_results) { should eql(expected_subject_results) }

    let(:expected_subject_results) do
      [
        Mutant::Result::Subject.new(
          subject:          subject_a,
          mutation_results: [
            Mutant::Result::Mutation.new(
              mutation: mutation_a1,
              runtime: 0.0,
              test_results: [test_report_a1]
            ),
            Mutant::Result::Mutation.new(
              mutation: mutation_a2,
              runtime: 0.0,
              test_results: [test_report_a1]
            )
          ],
          runtime:          0.0
        ),
        Mutant::Result::Subject.new(
          subject:          subject_b,
          mutation_results: [],
          runtime:          0.0
        )
      ]
    end
  end
end
