# frozen_string_literal: true

RSpec.describe Mutant::ContextMap::Loader do
  describe '.call' do
    def apply
      described_class.call(path:, world:)
    end

    let(:contents)  { JSON.dump(document) }
    let(:directory) { instance_double(Pathname, 'directory')  }
    let(:file)      { false                                   }
    let(:json)      { Mutant::Either::Right.new(JSON.parse(contents)) }
    let(:path)      { directory                               }
    let(:root)      { '/project'                              }

    let(:artifact) do
      instance_double(Pathname, 'artifact', file?: artifact_file, read: contents, to_s: 'coverage/coverage.json')
    end

    let(:artifact_file) { true }

    let(:world) do
      instance_double(Mutant::World).tap do |world|
        allow(world).to receive(:parse_json).with(contents).and_return(json)
      end
    end

    let(:meta) do
      { 'schema_version' => '1.3', 'root' => root }
    end

    let(:recorded_contexts) { ['spec/a_spec.rb:10', 'spec/b_spec.rb:20'] }

    let(:coverage) do
      { 'lib/subject.rb' => { 'lines' => [], 'contexts' => { '0' => '5', '1' => '8' } } }
    end

    let(:document) do
      { 'meta' => meta, 'contexts' => recorded_contexts, 'coverage' => coverage }
    end

    let(:expected_map) do
      Mutant::ContextMap.new(
        root:,
        tables: {
          '/project/lib/subject.rb' => {
            '/project/spec/a_spec.rb:10' => 5,
            '/project/spec/b_spec.rb:20' => 8
          }
        }
      )
    end

    before do
      allow(directory).to receive_messages(file?: file)

      allow(directory).to receive(:join).with('coverage.json').and_return(artifact) unless file
    end

    context 'on a directory' do
      it 'reads the report inside it' do
        expect(apply).to eql(right(expected_map))
      end
    end

    context 'on the report file itself' do
      let(:file) { true }

      let(:directory) do
        instance_double(Pathname, 'file path', file?: true, read: contents, to_s: 'other/coverage.json')
      end

      it 'reads it without joining a basename' do
        expect(apply).to eql(right(expected_map))
      end
    end

    context 'on a file key carrying a leading slash' do
      let(:coverage) do
        { '/lib/subject.rb' => { 'contexts' => { '0' => '5', '1' => '8' } } }
      end

      it 'resolves it against the recorded root' do
        expect(apply).to eql(right(expected_map))
      end
    end

    context 'on a file no recorded test executed' do
      let(:coverage) do
        super().merge('lib/untested.rb' => { 'lines' => [] })
      end

      it 'contributes nothing for it' do
        expect(apply).to eql(right(expected_map))
      end
    end

    context 'on a context id recorded twice' do
      let(:recorded_contexts) { ['spec/a_spec.rb:10', 'spec/a_spec.rb:10'] }

      let(:coverage) do
        { 'lib/subject.rb' => { 'contexts' => { '0' => '5', '1' => '3' } } }
      end

      let(:expected_map) do
        super().with(tables: { '/project/lib/subject.rb' => { '/project/spec/a_spec.rb:10' => 7 } })
      end

      it 'unions the lines under one id' do
        expect(apply).to eql(right(expected_map))
      end
    end

    context 'on a zero padded context index' do
      let(:recorded_contexts) { (0..8).map { |index| "spec/a_spec.rb:#{index}" } }

      let(:coverage) do
        { 'lib/subject.rb' => { 'contexts' => { '08' => '8' } } }
      end

      let(:expected_map) do
        super().with(tables: { '/project/lib/subject.rb' => { '/project/spec/a_spec.rb:8' => 8 } })
      end

      it 'reads it as decimal' do
        expect(apply).to eql(right(expected_map))
      end
    end

    context 'on a missing artifact' do
      let(:artifact_file) { false }

      it 'explains how to record one' do
        expect(apply.from_left).to start_with(<<~'MESSAGE'.strip)
          Test selection strategy `context_map` needs a per test coverage recording,
          but none exists at:

            coverage/coverage.json
        MESSAGE
      end

      it 'names simplecov, track_tests and the formatters that write it' do
        expect(apply.from_left).to include(
          'simplecov 1.2.0 or newer',
          'track_tests',
          'HTML formatter',
          'JSONFormatter',
          '--selection-path'
        )
      end
    end

    context 'on an unreadable artifact' do
      before do
        allow(artifact).to receive(:read).and_raise(Errno::EACCES, 'coverage/coverage.json')
      end

      it 'returns the system error' do
        expect(apply.from_left).to eql(<<~'MESSAGE')
          Unable to read the coverage recording at:

            coverage/coverage.json

          Permission denied - coverage/coverage.json
        MESSAGE
      end
    end

    context 'on unparsable JSON' do
      let(:json) { Mutant::Either::Left.new(JSON::ParserError.new('unexpected token')) }

      it 'returns the parser error' do
        expect(apply.from_left).to include('Unable to read the coverage recording at:', 'unexpected token')
      end
    end

    context 'without per test data' do
      let(:document) { { 'meta' => meta, 'coverage' => coverage } }

      it 'explains how to enable tracking' do
        expect(apply.from_left).to include(
          'has no per test data',
          'track_tests',
          'simplecov 1.2.0 or newer'
        )
      end
    end

    context 'on a future schema version' do
      let(:meta) { super().merge('schema_version' => '2.0') }

      it 'reports the schema it cannot read' do
        expect(apply.from_left).to include(
          'uses report schema version "2.0"',
          'record again with a simplecov that writes schema',
          'version 1'
        )
      end
    end

    context 'without a schema version' do
      let(:meta) { { 'root' => root } }

      it 'reports the schema it cannot read' do
        expect(apply.from_left).to include('uses report schema version nil')
      end
    end

    context 'on a non string schema version' do
      let(:meta) { super().merge('schema_version' => 1) }

      it 'reports the schema it cannot read' do
        expect(apply.from_left).to include('uses report schema version 1,')
      end
    end

    context 'without a coverage section' do
      let(:document) { { 'meta' => meta, 'contexts' => recorded_contexts } }

      it 'reports an unreadable report' do
        expect(apply.from_left).to include('is not a simplecov report mutant can read')
      end
    end

    context 'on a non string root' do
      let(:meta) { super().merge('root' => 1) }

      it 'reports an unreadable report' do
        expect(apply.from_left).to include('is not a simplecov report mutant can read')
      end
    end

    [
      '[]',
      '{}',
      '{"meta":"nope"}',
      '{"meta":{"schema_version":"1.3"}}'
    ].each do |malformed|
      context "on a document mutant cannot read #{malformed}" do
        let(:contents) { malformed                                        }
        let(:json)     { Mutant::Either::Right.new(JSON.parse(malformed)) }

        it 'reports an unreadable report' do
          expect(apply.from_left).to include('is not a simplecov report mutant can read')
        end
      end
    end

    [
      { 'contexts' => 'nope' },
      { 'contexts' => [1] },
      { 'contexts' => ['a:1', 1] },
      { 'coverage' => 'nope' },
      { 'coverage' => { 'lib/a.rb' => 'nope' } },
      { 'coverage' => { 'lib/subject.rb' => { 'contexts' => { '0' => '5' } }, 'lib/b.rb' => 'nope' } },
      { 'coverage' => { 'lib/a.rb' => { 'contexts' => 'nope' } } },
      { 'coverage' => { 'lib/a.rb' => { 'contexts' => { 'nope' => '1' } } } },
      { 'coverage' => { 'lib/a.rb' => { 'contexts' => { '0' => 'nope' } } } },
      { 'coverage' => { 'lib/a.rb' => { 'contexts' => { '0' => 1 } } } },
      { 'coverage' => { 'lib/a.rb' => { 'contexts' => { '9' => '1' } } } }
    ].each do |overrides|
      context "on a malformed recording #{overrides}" do
        let(:document) { super().merge(overrides) }

        it 'reports an unreadable report' do
          expect(apply.from_left).to include('is not a simplecov report mutant can read')
        end
      end
    end
  end
end
