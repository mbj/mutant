# frozen_string_literal: true

RSpec.describe Mutant::Expression::Source do
  let(:object) { parse_expression(input) }
  let(:input)  { 'source:lib/**/*.rb' }

  describe '#matcher' do
    def apply
      object.matcher(env: env)
    end

    let(:glob_expression) { 'lib/**/*.rb'                                      }
    let(:node_a)          { s(:nil)                                            }
    let(:node_b)          { s(:nil)                                            }
    let(:parser)          { instance_double(Mutant::Parser)                    }
    let(:path_a)          { instance_double(Pathname, :a)                      }
    let(:path_b)          { instance_double(Pathname, :b)                      }
    let(:pathname)        { class_double(Pathname)                             }
    let(:world)           { instance_double(Mutant::World, pathname: pathname) }

    let(:path_asts) do
      {
        path_a => ast_a,
        path_b => ast_b
      }
    end

    let(:config) do
      instance_double(
        Mutant::Config,
        matcher: instance_double(Mutant::Matcher::Config, diffs: [])
      )
    end

    let(:ast_a) do
      Mutant::AST.new(
        comment_associations: [],
        node:                 node_a
      )
    end

    let(:ast_b) do
      Mutant::AST.new(
        comment_associations: [],
        node:                 node_b
      )
    end

    let(:env) do
      instance_double(
        Mutant::Env,
        config:           config,
        matchable_scopes: [scope_a, scope_b],
        parser:           parser,
        world:            world
      )
    end

    let(:scope_a) do
      Mutant::Scope.new(
        expression: parse_expression('Foo::Bar'),
        raw:        Mutant
      )
    end

    let(:scope_b) do
      Mutant::Scope.new(
        expression: parse_expression('Bar::Baz'),
        raw:        Mutant
      )
    end

    before do
      allow(pathname).to receive_messages(glob: glob_result)
      allow(pathname).to receive(:new, &Pathname.method(:new))

      allow(parser).to receive(:call) do |path|
        path_asts.fetch(path)
      end
    end

    shared_examples 'performs glob' do
      it 'performs glob' do
        apply

        expect(pathname).to have_received(:glob).with(glob_expression)
      end
    end

    shared_examples 'no matchers' do
      it 'returns no matches' do
        expect(apply).to eql(Mutant::Matcher::Chain.new(matchers: []))
      end
    end

    describe '#call' do
      context 'when no files are matched' do
        let(:glob_result) { [] }

        include_examples 'no matchers'
        include_examples 'performs glob'
      end

      context 'when files are matched' do
        let(:glob_result) { [path_a, path_b] }

        context 'and files contain no matchable constants' do
          include_examples 'no matchers'
          include_examples 'performs glob'
        end

        context 'and files contain single matchable constants' do
          let(:node_a) { s(:module, s(:const, nil, :Foo)) }

          include_examples 'performs glob'

          it 'returns matcher' do
            expect(apply).to eql(
              Mutant::Matcher::Chain.new(
                matchers: [
                  Mutant::Matcher::Namespace.new(expression: parse_expression('Foo*'))
                ]
              )
            )
          end
        end

        context 'and files contain multiple matchable constants' do
          context 'without duplicates' do
            include_examples 'performs glob'

            let(:node_a) do
              s(:begin,
                s(:class, s(:const, nil, :Foo), nil),
                s(:module, s(:const, nil, :Bar)))
            end

            it 'returns matcher' do
              expect(apply).to eql(
                Mutant::Matcher::Chain.new(
                  matchers: [
                    Mutant::Matcher::Namespace.new(expression: parse_expression('Foo*')),
                    Mutant::Matcher::Namespace.new(expression: parse_expression('Bar*'))
                  ]
                )
              )
            end
          end

          context 'with duplicates' do
            include_examples 'performs glob'

            let(:node_a) do
              s(:begin,
                s(:module, s(:const, nil, :Foo)),
                s(:module, s(:const, nil, :Foo)))
            end

            it 'returns matcher' do
              expect(apply).to eql(
                Mutant::Matcher::Chain.new(
                  matchers: [
                    Mutant::Matcher::Namespace.new(expression: parse_expression('Foo*'))
                  ]
                )
              )
            end
          end
        end
      end
    end
  end

  describe '#syntax' do
    def apply
      object.syntax
    end

    it 'returns input' do
      expect(apply).to eql(input)
    end
  end

  describe '.try_parse' do
    def apply
      described_class.try_parse(input)
    end

    context 'on valid input' do
      it 'returns expected matcher' do
        expect(apply).to eql(described_class.new(glob_expression: 'lib/**/*.rb'))
      end
    end

    context 'on invalid input' do
      let(:input) { '' }

      it 'returns nil' do
        expect(apply).to be(nil)
      end
    end
  end
end
