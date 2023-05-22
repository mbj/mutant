# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Method::Instance, '#call' do
  subject { object.call(env) }

  let(:base)          { TestApp::InstanceMethodTests                             }
  let(:method)        { scope.instance_method(method_name)                       }
  let(:method_arity)  { 0                                                        }
  let(:method_name)   { :foo                                                     }
  let(:object)        { described_class.new(scope: scope, target_method: method) }
  let(:source_path)   { MutantSpec::ROOT.join('test_app/lib/test_app.rb')        }
  let(:type)          { :def                                                     }
  let(:config)        { Mutant::Config::DEFAULT                                  }

  let(:world) do
    instance_double(
      Mutant::World,
      pathname: Pathname
    )
  end

  let(:env) do
    instance_double(
      Mutant::Env,
      config: config,
      parser: Fixtures::TEST_ENV.parser,
      world:  world
    )
  end

  def name
    node.children.fetch(0)
  end

  def arguments
    node.children.fetch(1)
  end

  context 'when method is defined inside file that does not end with .rb' do
    let(:scope)           { base::WithMemoizer               }
    let(:source_location) { [file, instance_double(Integer)] }
    let(:file)            { 'example.erb'                    }

    let(:method) do
      instance_double(
        Method,
        name:            :some_method,
        owner:           nil,
        source_location: source_location
      )
    end

    let(:expected_warnings) do
      [
        "#{method} does not have a valid source location, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'when method is defined inside of a file removed by a diff filter' do
    let(:config)            { super().with(matcher: super().matcher.with(diffs: diffs)) }
    let(:diff_a)            { instance_double(Mutant::Repository::Diff, :diff_a)        }
    let(:diff_a_touches?)   { false                                                     }
    let(:diff_b)            { instance_double(Mutant::Repository::Diff, :diff_b)        }
    let(:diff_b_touches?)   { false                                                     }
    let(:diffs)             { []                                                        }
    let(:expected_warnings) { []                                                        }
    let(:method_line)       { 13                                                        }
    let(:method_name)       { :bar                                                      }
    let(:scope)             { base::WithMemoizer                                        }

    before do
      allow(diff_a).to receive(:touches_path?).with(source_path).and_return(diff_a_touches?)
      allow(diff_b).to receive(:touches_path?).with(source_path).and_return(diff_b_touches?)
    end

    context 'on absent diff filter' do
      include_examples 'a method matcher'
    end

    context 'on single diff filter' do
      let(:diffs) { [diff_a] }

      context 'on not touching that diff' do
        include_examples 'skipped candidate'
      end

      context 'on touching that diff' do
        let(:diff_a_touches?) { true }

        include_examples 'a method matcher'
      end
    end

    context 'on multiple diff filter' do
      let(:diffs) { [diff_a, diff_b] }

      context 'on not touching any of the diffs' do
        include_examples 'skipped candidate'
      end

      context 'on touching one diff' do
        let(:diff_a_touches?) { true }

        include_examples 'skipped candidate'
      end

      context 'on touching both diffs' do
        let(:diff_a_touches?) { true }
        let(:diff_b_touches?) { true }

        include_examples 'a method matcher'
      end
    end
  end

  context 'when method is defined inside eval' do
    let(:scope)  { base::WithMemoizer           }
    let(:method) { scope.instance_method(:boz)  }

    let(:expected_warnings) do
      [
        "#{method} does not have a valid source location, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'when method is defined without source location' do
    let(:scope)  { Module                            }
    let(:method) { scope.instance_method(:object_id) }

    let(:expected_warnings) do
      [
        "#{method} does not have a valid source location, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'in module eval' do
    let(:scope) { base::InModuleEval }

    let(:expected_warnings) do
      [
        "#{method} is dynamically defined in a closure, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'in class eval' do
    let(:scope) { base::InClassEval }

    let(:expected_warnings) do
      [
        "#{method} is dynamically defined in a closure, unable to emit subject"
      ]
    end

    include_examples 'skipped candidate'
  end

  context 'when method is defined once' do
    let(:method_name) { :bar               }
    let(:scope)       { base::WithMemoizer }
    let(:method_line) { 13                 }

    it_should_behave_like 'a method matcher'

    let(:context) do
      Mutant::Context.new(
        scope:       TestApp::InstanceMethodTests::WithMemoizer,
        source_path: MutantSpec::ROOT.join('test_app', 'lib', 'test_app.rb')
      )
    end

    let(:expected_subjects) do
      [
        Mutant::Subject::Method::Instance.new(
          config:     Mutant::Subject::Config::DEFAULT,
          context:    context,
          node:       s(:def, :bar, s(:args), nil),
          visibility: expected_visibility
        )
      ]
    end

    %i[public protected private].each do |visibility|
      context 'with %s visibility' % visibility do
        let(:expected_visibility) { visibility }

        before { context.scope.__send__(visibility, method_name) }

        it 'returns expected subjects' do
          expect(subject).to eql(expected_subjects)
        end
      end
    end
  end

  context 'when method is defined once with a memoizer' do
    let(:scope)       { base::WithMemoizer }
    let(:method_line) { 15                 }

    it_should_behave_like 'a method matcher'
  end

  context 'when method is defined multiple times' do
    context 'on different lines' do
      let(:scope)        { base::DefinedMultipleTimes::DifferentLines }
      let(:method_line)  { 24                                         }
      let(:method_arity) { 1                                          }

      it_should_behave_like 'a method matcher'
    end

    context 'on the same line' do
      let(:scope)        { base::DefinedMultipleTimes::SameLineSameScope }
      let(:method_line)  { 29                                            }
      let(:method_arity) { 1                                             }

      it_should_behave_like 'a method matcher'
    end

    context 'on the same line with different scope' do
      let(:scope)        { base::DefinedMultipleTimes::SameLineDifferentScope }
      let(:method_line)  { 33                                                 }
      let(:method_arity) { 1                                                  }

      it_should_behave_like 'a method matcher'
    end
  end

  context 'with sorbet signature' do
    let(:scope)        { base::WithSignature }
    let(:method_line)  { 116                 }
    let(:method_arity) { 0                   }

    it_should_behave_like 'a method matcher'
  end

  context 'on delegate class' do
    let(:scope)        { TestApp::DelegateTest }
    let(:method_line)  { 134                   }
    let(:method_arity) { 0                     }

    it_should_behave_like 'a method matcher'
  end

  context 'on inline disabled method' do
    let(:scope)        { TestApp::InlineDisabled }
    let(:method_line)  { 148                     }
    let(:method_arity) { 0                       }

    it_should_behave_like 'a method matcher' do
      it 'returns disabled inline config' do
        expect(mutation_subject.config.inline_disable).to be(true)
      end
    end
  end
end
