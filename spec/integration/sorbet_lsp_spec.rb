# frozen_string_literal: true

RSpec.describe 'Sorbet LSP Integration', :slow do
  let(:project_root) { Pathname.new(__dir__).parent.parent.join('test_app') }

  describe Mutant::Sorbet::LSP::Client do
    let(:client) { described_class.new(project_root: project_root) }

    after do
      client.stop if client.instance_variable_get(:@running)
    end

    describe '#start' do
      it 'starts the LSP server and initializes' do
        expect { client.start }.not_to raise_error
        expect(client.instance_variable_get(:@running)).to be(true)
      end
    end

    describe '#stop' do
      it 'stops the LSP server' do
        client.start
        expect { client.stop }.not_to raise_error
        expect(client.instance_variable_get(:@running)).to be(false)
      end
    end

    context 'with running server' do
      before { client.start }

      describe '#open_document' do
        let(:file_path) { project_root.join('lib', 'test_app.rb') }
        let(:content) { file_path.read }

        it 'opens a document without error' do
          expect { client.open_document(file_path: file_path, content: content) }.not_to raise_error
        end
      end

      describe '#diagnostics_for' do
        let(:file_path) { project_root.join('lib', 'test_app.rb') }
        let(:content) { file_path.read }

        before do
          client.open_document(file_path: file_path, content: content)
          client.wait_for_diagnostics
        end

        it 'returns diagnostics for the file' do
          diagnostics = client.diagnostics_for(file_path)
          expect(diagnostics).to be_an(Array)
        end
      end

      describe '#change_document' do
        let(:file_path) { project_root.join('lib', 'sorbet_example.rb') }
        let(:original_content) { file_path.read }
        let(:mutated_content) do
          # Introduce a type error: change return type from Integer to String
          original_content.sub(
            /def add\(x, y\)\s+x \+ y\s+end/m,
            "def add(x, y)\n    (x + y).to_s  # Returns String instead of Integer\n  end"
          )
        end

        before do
          client.open_document(file_path: file_path, content: original_content)
          client.wait_for_diagnostics
        end

        it 'detects type errors when mutation breaks return type' do
          baseline_diagnostics = client.diagnostics_for(file_path)

          # Baseline should have no errors
          expect(baseline_diagnostics).to be_empty

          # Apply mutation that breaks return type
          client.change_document(file_path: file_path, content: mutated_content, version: 2)
          client.wait_for_diagnostics

          new_diagnostics = client.diagnostics_for(file_path)

          # Should have exactly one new type error
          expect(new_diagnostics.length).to eq(1)

          error = new_diagnostics.first
          # Verify it's a type error about return type mismatch
          expect(error[:message]).to match(/Expected `Integer` but found `String`/)
          expect(error[:message]).to match(/method result type/)
        end

        it 'detects no errors when mutation preserves types' do
          baseline_diagnostics = client.diagnostics_for(file_path)
          expect(baseline_diagnostics).to be_empty

          # Apply type-safe mutation (subtract instead of add)
          type_safe_mutation = original_content.sub(
            /def add\(x, y\)\s+x \+ y\s+end/m,
            "def add(x, y)\n    x - y  # Still returns Integer\n  end"
          )

          client.change_document(file_path: file_path, content: type_safe_mutation, version: 2)
          client.wait_for_diagnostics

          new_diagnostics = client.diagnostics_for(file_path)

          # Should still have no errors - mutation is type-safe
          expect(new_diagnostics).to be_empty
        end
      end
    end
  end

  describe Mutant::Sorbet::TypeChecker do
    let(:lsp_client) { Mutant::Sorbet::LSP::Client.new(project_root: project_root).start }
    let(:type_checker) { described_class.new(project_root: project_root, lsp_client: lsp_client) }

    after do
      lsp_client.stop
    end

    describe '.for_process' do
      it 'returns a type checker for current process' do
        checker = described_class.for_process(project_root: project_root)
        expect(checker).to be_a(described_class)
        expect(checker.lsp_client).to be_a(Mutant::Sorbet::LSP::Client)

        # Clean up
        checker.cleanup
      end
    end

    describe '.for_mutation' do
      it 'creates isolated type checker for each mutation' do
        # Pre-warm parent cache
        described_class.warmup(project_root: project_root)

        # Each mutation gets its own type checker instance
        checker1 = described_class.for_mutation(
          project_root: project_root,
          parent_cache_dir: nil,
          mutation_index: 0
        )

        checker2 = described_class.for_mutation(
          project_root: project_root,
          parent_cache_dir: nil,
          mutation_index: 1
        )

        # Different instances for different mutations
        expect(checker1).not_to equal(checker2)

        # Each has its own cache directory
        expect(checker1.cache_dir.to_s).to include('mutation-0')
        expect(checker2.cache_dir.to_s).to include('mutation-1')

        # Clean up
        checker1.cleanup
        checker2.cleanup
      end
    end
  end
end
