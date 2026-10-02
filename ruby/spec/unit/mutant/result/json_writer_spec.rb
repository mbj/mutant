# frozen_string_literal: true

RSpec.describe Mutant::Result::JSONWriter do
  let(:dir)       { instance_double(Pathname, :dir) }
  let(:path)      { instance_double(Pathname, :path) }
  let(:tmp_path)  { instance_double(Pathname, :tmp_path) }
  let(:pathname)  { class_double(Pathname) }
  let(:process)   { class_double(Process) }

  let(:world) do
    instance_double(
      Mutant::World,
      pathname:,
      process:
    )
  end

  let(:env) do
    instance_double(Mutant::Env, world:)
  end

  let(:result) do
    instance_double(Mutant::Result::Env, killtime: 10.5, runtime: 2.5, subject_results: [])
  end

  let(:object) { described_class.new(env:, result:) }

  describe '#call' do
    before do
      allow(pathname).to receive(:new).with('.mutant/results').and_return(dir)
      allow(dir).to receive(:mkpath)
      allow(dir).to receive(:join).with("#{Mutant::SESSION_ID}.json.gz").and_return(path)
      allow(dir).to receive(:join).with("#{Mutant::SESSION_ID}.json.gz.tmp").and_return(tmp_path)
      allow(tmp_path).to receive(:binwrite)
      allow(tmp_path).to receive(:rename)
      allow(process).to receive(:pid).and_return(42)
    end

    it 'creates the results directory' do
      object.call

      expect(dir).to have_received(:mkpath)
    end

    # Written beside the session file and renamed over it, so a reader
    # that opens the session mid-write never sees a truncated document.
    it 'renames the temporary file over the session file' do
      object.call

      expect(tmp_path).to have_received(:rename).with(path)
    end

    it 'writes gzip compressed JSON to the temporary file' do
      object.call

      expect(tmp_path).to have_received(:binwrite) do |gzip|
          json = Zlib.gunzip(gzip)

          data = JSON.parse(json)

          expect(data.fetch('session_id')).to eql(Mutant::SESSION_ID)
          expect(data.fetch('mutant_version')).to eql(Mutant::VERSION)
          expect(data.fetch('ruby_version')).to eql(RUBY_VERSION)
          expect(data.fetch('pid')).to eql(42)
          expect(data.fetch('killtime')).to eql(10.5)
          expect(data.fetch('runtime')).to eql(2.5)
          expect(data.fetch('subject_results')).to eql([])
      end
    end

    it 'returns the path' do
      expect(object.call).to be(path)
    end

    context 'with a covered and an alive mutation' do
      setup_shared_context

      let(:world) { instance_double(Mutant::World, pathname:, process:) }
      let(:env)   { instance_double(Mutant::Env, world:) }

      let(:result) do
        instance_double(Mutant::Result::Env, killtime: 10.5, runtime: 2.5, subject_results: [subject_a_result])
      end

      with(:mutation_a_isolation_result) { { log: Mutant::LogCapture::String.new(content: 'killed output') } }
      with(:mutation_b_isolation_result) { { log: Mutant::LogCapture::String.new(content: 'alive output') } }
      with(:mutation_b_criteria_result)  { { test_result: false }                                           }

      def written_logs
        logs = nil

        expect(tmp_path).to have_received(:binwrite) do |gzip|
          json = Zlib.gunzip(gzip)

          logs = JSON.parse(json).fetch('subject_results').flat_map do |subject_result|
            subject_result.fetch('coverage_results').map do |coverage_result|
              coverage_result.dig('mutation_result', 'isolation_result', 'log')
            end
          end
        end

        logs
      end

      # The output of the tests that killed a mutation is never read
      # back, and is often most of the session file.
      it 'writes the log of the alive mutation alone' do
        object.call

        expect(written_logs).to eql(
          [
            { 'type' => 'string', 'content' => ''             },
            { 'type' => 'string', 'content' => 'alive output' }
          ]
        )
      end

      it 'keeps the rest of each coverage result' do
        object.call

        expect(tmp_path).to have_received(:binwrite) do |gzip|
          json = Zlib.gunzip(gzip)

          coverage_results = JSON.parse(json).dig('subject_results', 0, 'coverage_results')

          expect(coverage_results.map { |coverage_result| coverage_result.dig('mutation_result', 'mutation_source') })
            .to eql([mutation_a.source, mutation_b.source])
          expect(coverage_results.map { |coverage_result| coverage_result.dig('criteria_result', 'test_result') })
            .to eql([true, false])
        end
      end
    end
  end
end
