# frozen_string_literal: true

RSpec.describe Mutant::Subject::Config do
  describe '.parse' do
    def apply
      described_class.parse(
        comments: comments,
        mutation: mutation_config
      )
    end

    let(:mutation_config) { Mutant::Mutation::Config::DEFAULT }

    let(:comments) do
      node, comments = Unparser.parse_with_comments(source)

      Parser::Source::Comment.associate_by_identity(node, comments).fetch(node, [])
    end

    shared_examples 'returns default config' do
      it 'returns default config' do
        expect(apply).to eql(described_class::DEFAULT)
      end
    end

    shared_examples 'returns disabled config' do
      it 'returns default config' do
        expect(apply).to eql(
          described_class.new(
            inline_disable: true,
            mutation:       mutation_config
          )
        )
      end
    end

    context 'on empty comments' do
      let(:source) do
        <<~'RUBY'
          def foo
          end
        RUBY
      end

      include_examples 'returns default config'
    end

    context 'on comment not mentioning a mutant disable' do
      context 'in a line comment' do
        let(:source) do
          <<~'RUBY'
            # rubocop:disable Metrics/Something
            def foo
            end
          RUBY
        end

        include_examples 'returns default config'
      end

      context 'in a block comment' do
        let(:source) do
          <<~'RUBY'
            =begin
            rubocop:disable Metrics/Something
            =end
            def foo
            end
          RUBY
        end

        include_examples 'returns default config'
      end
    end

    context 'on comment mentioning a mutant disable' do
      context 'in a block comment' do
        let(:source) do
          <<~'RUBY'
            =begin
            mutant:disable
            =end
            def foo
            end
          RUBY
        end

        include_examples 'returns disabled config'
      end

      context 'in a line comment' do
        context 'with space' do
          let(:source) do
            <<~'RUBY'
              # mutant:disable
              def foo
              end
            RUBY
          end

          include_examples 'returns disabled config'
        end

        context 'without space' do
          let(:source) do
            <<~'RUBY'
              #mutant:disable
              def foo
              end
            RUBY
          end

          include_examples 'returns disabled config'
        end
      end
    end
  end
end
