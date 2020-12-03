# frozen_string_literal: true

RSpec.describe Mutant::License do
  def apply
    described_class.apply(world)
  end

  let(:gem)              { class_double(Gem, loaded_specs: loaded_specs)  }
  let(:gem_method)       { instance_double(Method)                        }
  let(:gem_path)         { '/path/to/mutant-license'                      }
  let(:gem_pathname)     { instance_double(Pathname)                      }
  let(:json)             { class_double(JSON)                             }
  let(:kernel)           { class_double(Kernel)                           }
  let(:license_json)     { instance_double(Object)                        }
  let(:license_pathname) { instance_double(Pathname)                      }
  let(:load_json)        { true                                           }
  let(:loaded_specs)     { { 'mutant-license' => spec }                   }
  let(:pathname)         { class_double(Pathname)                         }
  let(:stderr)           { instance_double(IO)                            }
  let(:subscription)     { instance_double(Mutant::License::Subscription) }

  let(:subscription_result) do
    MPrelude::Either::Right.new(subscription)
  end

  let(:spec) do
    instance_double(
      Gem::Specification,
      full_gem_path: gem_path
    )
  end

  let(:world) do
    instance_double(
      Mutant::World,
      gem:        gem,
      gem_method: gem_method,
      json:       json,
      kernel:     kernel,
      pathname:   pathname,
      stderr:     stderr
    )
  end

  before do
    allow(gem_method).to receive_messages(call: undefined)
    allow(gem_pathname).to receive_messages(join: license_pathname)
    allow(json).to receive_messages(load: license_json)
    allow(kernel).to receive_messages(sleep: undefined)
    allow(pathname).to receive_messages(new: gem_pathname)
    allow(Mutant::License::Subscription).to receive_messages(load: subscription_result)
  end

  shared_examples 'license load' do
    it 'performs IO in expected sequence' do
      apply

      expect(gem_method)
        .to have_received(:call)
        .with('mutant-license', '>= 0.1', '< 0.3')
        .ordered

      if load_json
        expect(json)
          .to have_received(:load)
          .with(license_pathname)
          .ordered
      end
    end

    it 'builds correct license.json path' do
      if load_json
        apply

        expect(pathname).to have_received(:new).with(gem_path)
        expect(gem_pathname).to have_received(:join).with('license.json')
      end
    end

    it 'loads license json' do
      if load_json
        apply

        expect(Mutant::License::Subscription)
          .to have_received(:load)
          .with(world, license_json)
      end
    end

    it 'returns expected result' do
      expect(apply).to eql(expected_result)
    end
  end

  def self.it_fails_with_message(message)
    let(:expected_result) do
      MPrelude::Either::Left.new(message)
    end

    include_examples 'license load'
  end

  context 'on successful license load' do
    include_examples 'license load'

    let(:expected_result) { MPrelude::Either::Right.new(subscription) }
  end

  context 'when mutant-license gem cannot be loaded' do
    let(:load_json) { false }

    def self.setup_error(message)
      before do
        allow(gem_method).to receive(:call).and_raise(Gem::LoadError, message)
      end
    end

    context 'while the mutant license gem from rubygems is present' do
      setup_error %{can't activate mutant-license (~> 0.1.0), already activated mutant-license-0.0.0.}

      it_fails_with_message 'mutant-license gem from rubygems.org is a dummy'
    end

    context 'with other error message' do
      setup_error 'test-error'

      it_fails_with_message 'test-error'
    end
  end
end
