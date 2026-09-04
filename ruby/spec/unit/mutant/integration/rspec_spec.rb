# frozen_string_literal: true

require 'mutant/integration/rspec'

RSpec.describe Mutant::Integration::Rspec do
  let(:object) do
    described_class.new(
      arguments:         integration_arguments,
      expression_parser: Mutant::Config::DEFAULT.expression_parser,
      world:
    )
  end

  let(:expected_rspec_cli)    { %w[--fail-fast spec]                               }
  let(:integration_arguments) { []                                                 }
  let(:ordering_registry)     { instance_double(RSpec::Core::Ordering::Registry)   }
  let(:rspec_configuration)   { instance_double(RSpec::Core::Configuration)        }
  let(:rspec_options)         { instance_double(RSpec::Core::ConfigurationOptions) }
  let(:rspec_runner)          { instance_double(RSpec::Core::Runner)               }
  let(:world)                 { fake_world                                         }
  let(:is_quitting)           { false                                              }
  let(:wants_to_quit)         { false                                              }

  let(:example_a) do
    double(
      'Example A',
      id:       'example-a',
      metadata: {
        location:         'example-a-location',
        full_description: 'example-a-full-description'
      }
    )
  end

  let(:example_b) do
    double(
      'Example B',
      id:       'example-b',
      metadata: {
        location:         'example-b-location',
        full_description: 'example-b-full-description',
        mutant:           false
      }
    )
  end

  let(:example_c) do
    double(
      'Example C',
      id:       'example-c',
      metadata: {
        location:         'example-c-location',
        full_description: 'Example::C blah'
      }
    )
  end

  let(:example_d) do
    double(
      'Example D',
      id:       'example-d',
      metadata: {
        location:         'example-d-location',
        full_description: "Example::D\nblah"
      }
    )
  end

  let(:example_e) do
    double(
      'Example E',
      id:       'example-e',
      metadata: {
        location:          'example-e-location',
        full_description:  'Example::E',
        mutant_expression: 'Foo'
      }
    )
  end

  let(:example_f) do
    double(
      'Example F',
      id:       'example-f',
      metadata: {
        location:          'example-f-location',
        full_description:  'Example::F',
        mutant_expression: %w[Foo Bar]
      }
    )
  end

  let(:example_g) do
    double(
      'Example G',
      id:       'example-g',
      metadata: {
        location:         'example-g-location',
        full_description: ''
      }
    )
  end

  let(:leaf_example_group) do
    class_double(
      RSpec::Core::ExampleGroup,
      'leaf example group',
      examples: [example_a, example_b, example_c, example_d, example_e, example_f, example_g]
    )
  end

  let(:root_example_group) do
    class_double(
      RSpec::Core::ExampleGroup,
      'root example group',
      examples: []
    )
  end

  let(:example_groups) do
    [root_example_group]
  end

  let(:filtered_examples) do
    {
      root_example_group => root_example_group.examples.dup,
      leaf_example_group => leaf_example_group.examples.dup
    }
  end

  let(:rspec_world) do
    instance_double(
      RSpec::Core::World,
      example_groups:,
      filtered_examples:,
      ordered_example_groups:,
      wants_to_quit:
    )
  end

  let(:ordered_example_groups) { double('ordered_example_groups') }

  let(:all_tests) do
    [
      Mutant::Test.new(
        id:          'rspec:0:example-a-location/example-a-full-description',
        expressions: [parse_expression('*')],
        location:    'example-a-location'
      ),
      Mutant::Test.new(
        id:          'rspec:1:example-b-location/example-b-full-description',
        expressions: [parse_expression('*')],
        location:    'example-b-location'
      ),
      Mutant::Test.new(
        id:          'rspec:2:example-c-location/Example::C blah',
        expressions: [parse_expression('Example::C')],
        location:    'example-c-location'
      ),
      Mutant::Test.new(
        id:          "rspec:3:example-d-location/Example::D\nblah",
        expressions: [parse_expression('*')],
        location:    'example-d-location'
      ),
      Mutant::Test.new(
        id:          'rspec:4:example-e-location/Example::E',
        expressions: [parse_expression('Foo')],
        location:    'example-e-location'
      ),
      Mutant::Test.new(
        id:          'rspec:5:example-f-location/Example::F',
        expressions: [parse_expression('Foo'), parse_expression('Bar')],
        location:    'example-f-location'
      ),
      Mutant::Test.new(
        id:          'rspec:6:example-g-location/',
        expressions: [parse_expression('*')],
        location:    'example-g-location'
      )
    ]
  end

  before do
    allow(root_example_group).to receive_messages(
      descendants: [root_example_group, leaf_example_group]
    )

    allow(RSpec::Core::ConfigurationOptions).to receive(:new)
      .with(expected_rspec_cli)
      .and_return(rspec_options)

    expect(RSpec::Core::Runner).to receive(:new)
      .with(rspec_options)
      .and_return(rspec_runner)

    expect(RSpec).to receive_messages(world: rspec_world)

    allow(rspec_configuration).to receive(:start_time=)
    allow(rspec_configuration).to receive(:force)
    allow(rspec_configuration).to receive(:reporter)
    allow(rspec_configuration).to receive(:reset_reporter)
    allow(rspec_configuration).to receive_messages(ordering_registry:)
    allow(ordering_registry).to receive(:register)

    allow(leaf_example_group).to receive_messages(
      id:            'leaf',
      parent_groups: [leaf_example_group, root_example_group]
    )

    allow(root_example_group).to receive_messages(id: 'root')

    leaf_example_group.examples.each do |example|
      allow(example).to receive_messages(example_group: leaf_example_group)
    end
    allow(rspec_runner).to receive_messages(configuration: rspec_configuration)
    allow(world.time).to receive_messages(now: Time.at(10))
    allow(world.timer).to receive(:elapsed).and_return(2.0).and_yield
    allow(world.timer).to receive_messages(now: 1.0)
  end

  context 'on overwritten arguments' do
    let(:expected_rspec_cli)    { integration_arguments     }
    let(:integration_arguments) { %w[argument-a argument-b] }

    subject { object.all_tests }

    it { is_expected.to eql(all_tests) }
  end

  describe '#all_tests' do
    subject { object.all_tests }

    it { is_expected.to eql(all_tests) }
  end

  describe '#available_tests' do
    subject { object.available_tests }

    it { is_expected.to eql(all_tests.take(1) + all_tests.drop(2)) }
  end

  describe '#setup' do
    subject { object.setup }

    before do
      expect(rspec_runner).to receive(:setup) do |error, stdout|
        expect(error).to be(world.stderr)
        expect(stdout).to be(world.stdout)
      end
    end

    shared_examples 'success' do
      it { is_expected.to be(object) }

      it 'freezes object' do
        expect { subject }.to change { object.frozen? }.from(false).to(true)
      end
    end

    context 'on success' do
      include_examples 'success'
    end

    shared_examples 'setup failure' do
      def apply
        object.setup
      end

      it 'raises expeced error' do
        expect { apply }.to raise_error('RSpec setup failure')
      end
    end

    context 'on rspec setup failure' do
      context 'when rspec wants to quit' do
        let(:wants_to_quit) { true }

        include_examples 'setup failure'
      end

      context 'when rspec does not want to quit' do
        before do
          allow(rspec_world).to receive_messages(respond_to?: supports_is_quitting)
        end

        shared_examples 'support query' do
          it 'queries support' do
            begin
              subject
            rescue # rubocop:disable Lint/SuppressedException
            end

            expect(rspec_world).to have_received(:respond_to?).with(:rspec_is_quitting)
          end
        end

        context 'and rspec supports is currently quitting' do
          let(:supports_is_quitting) { true }

          before do
            allow(rspec_world).to receive_messages(rspec_is_quitting:)
          end

          context 'and its currently quitting' do
            let(:rspec_is_quitting) { true }

            include_examples 'setup failure'
            include_examples 'support query'
          end

          context 'and its not currently quitting' do
            let(:rspec_is_quitting) { false }

            include_examples 'success'
            include_examples 'support query'
          end
        end

        context 'and rspec does not support is currently quitting' do
          let(:supports_is_quitting) { false }

          include_examples 'success'
          include_examples 'support query'
        end
      end
    end
  end

  describe '#call' do
    subject { object.setup; object.call(tests) }

    let(:tests) { [all_tests.fetch(0)] }

    before do
      expect(rspec_runner).to receive(:setup) do |error, stdout|
        expect(error).to be(world.stderr)
        expect(stdout).to be(world.stdout)
      end
      allow(rspec_runner).to receive_messages(run_specs: exit_status)
    end

    shared_examples '#call' do
      it 'calls rspec runner with ordeded examples' do
        subject

        expect(rspec_runner).to have_received(:run_specs).with(ordered_example_groups)
      end

      it 'updates rspec start time' do
        subject

        expect(rspec_configuration).to have_received(:start_time=).with(Time.at(8))
      end

      it 'resets reporter' do
        subject

        expect(rspec_configuration).to have_received(:reset_reporter)
      end

      it 'modifies filtered examples to selection' do
        subject

        expect(filtered_examples).to eql(
          root_example_group => [],
          leaf_example_group => [example_a]
        )
      end
    end

    context 'on unsuccessful exit' do
      let(:exit_status) { 1 }

      include_examples '#call'

      it 'should return failed result' do
        expect(subject).to eql(
          Mutant::Result::Test.new(
            job_index: nil,
            output:    Mutant::LogCapture::String.new(content: ''),
            passed:    false,
            runtime:   0.0
          )
        )
      end
    end

    context 'on successful exit' do
      let(:exit_status) { 0 }

      include_examples '#call'

      it 'should return passed result' do
        expect(subject).to eql(
          Mutant::Result::Test.new(
            job_index: nil,
            output:    Mutant::LogCapture::String.new(content: ''),
            passed:    true,
            runtime:   0.0
          )
        )
      end
    end

    context 'on multiple calls' do
      let(:exit_status) { 0 }

      let(:tests_initial)  { all_tests.take(1)         }
      let(:tests_followup) { all_tests.drop(1).take(1) }

      def apply
        object.setup
        object.call(tests_initial)
        object.call(tests_followup)
      end

      it 'modifies filtered examples to selection' do
        apply

        expect(filtered_examples).to eql(
          root_example_group => [],
          leaf_example_group => [example_b]
        )
      end
    end

    context 'on more than one test' do
      let(:exit_status) { 0                                            }
      let(:registered)  { []                                           }
      let(:tests)       { [all_tests.fetch(2), all_tests.fetch(0)]     }

      before do
        registered = registered()

        allow(ordering_registry).to receive(:register) do |name, strategy|
          registered << [name, strategy]
        end
      end

      it 'installs the ordering rspec runs by' do
        subject

        expect(registered.map(&:first)).to eql([:global])
      end

      it 'installs a strategy of its own kind' do
        subject

        _name, ordering = registered.fetch(0)

        expect(ordering).to be_a(Mutant::Integration::Rspec::Ordering)
      end

      it 'orders the examples the way the tests were given' do
        subject

        _name, ordering = registered.fetch(0)

        expect(ordering.order([example_a, example_c])).to eql([example_c, example_a])
      end

      it 'orders a group holding no selected example last' do
        subject

        _name, ordering = registered.fetch(0)
        other           = class_double(RSpec::Core::ExampleGroup, 'other example group', id: 'other')

        expect(ordering.order([other, leaf_example_group])).to eql([leaf_example_group, other])
      end
    end
  end
end
