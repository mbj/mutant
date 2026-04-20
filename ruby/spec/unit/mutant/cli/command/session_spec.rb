# frozen_string_literal: true

# rubocop:disable Style/FormatStringToken
RSpec.describe Mutant::CLI::Command::Session do
  let(:stderr) { instance_double(IO, :stderr, tty?: false) }
  let(:stdout) { instance_double(IO, :stdout, tty?: false) }
  let(:timer)  { instance_double(Mutant::Timer) }

  let(:world) do
    instance_double(
      Mutant::World,
      kernel:   class_double(Kernel),
      pathname: class_double(Pathname),
      recorder: instance_double(Mutant::Segment::Recorder),
      stderr:,
      stdout:,
      timer:
    )
  end

  let(:results_dir) { instance_double(Pathname, :results_dir) }

  before do
    allow(world).to receive(:record) { |_name, &block| block.call }
    allow(world).to receive(:parse_json) { |string| Mutant::Either.wrap_error(JSON::ParserError) { JSON.parse(string) } }
  end

  def parse(arguments)
    Mutant::CLI.parse(
      arguments: ['session', *arguments],
      world:
    )
  end

  def apply(arguments)
    parse(arguments).from_right.call
  end

  let(:session_id) { '019cf6f1-77e8-74b6-82db-f8b5faf570cd' }

  let(:valid_session_json) do
    {
      'killtime'        => 10.5,
      'mutant_version'  => '1.0.0',
      'pid'             => 12_345,
      'ruby_version'    => '4.0.1',
      'runtime'         => 2.5,
      'session_id'      => session_id,
      'subject_results' => []
    }.to_json
  end

  let(:expected_timestamp) { '2026-03-16 13:59:05' }

  let(:list_header) do
    '%-6s  %-10s  %-8s  %-10s  %-10s  %-36s  %s' \
      % ['ALIVE', 'MUTATIONS', 'SUBJECTS', 'RUNTIME', 'KILLTIME', 'SESSION ID', 'TIMESTAMP']
  end

  let(:list_row) do
    '%-6s  %-10s  %-8s  %-10s  %-10s  %-36s  %s' % [0, 0, 0, '2.50s', '10.50s', session_id, expected_timestamp]
  end

  def pathname_new(path, result)
    {
      receiver:  world.pathname,
      selector:  :new,
      arguments: [path],
      reaction:  { return: result }
    }
  end

  def directory_check(dir, result)
    {
      receiver: dir,
      selector: :directory?,
      reaction: { return: result }
    }
  end

  def glob(dir, pattern, result)
    {
      receiver:  dir,
      selector:  :glob,
      arguments: [pattern],
      reaction:  { return: result }
    }
  end

  def read_file(path, content)
    {
      receiver: path,
      selector: :read,
      reaction: { return: content }
    }
  end

  def puts_stdout(message)
    {
      receiver:  stdout,
      selector:  :puts,
      arguments: [message]
    }
  end

  def puts_stderr(message)
    {
      receiver:  stderr,
      selector:  :puts,
      arguments: [message]
    }
  end

  describe 'list' do
    context 'when results directory does not exist' do
      let(:raw_expectations) do
        [
          puts_stdout(list_header),
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, false)
        ]
      end

      it 'prints header only' do
        verify_events { expect(apply(%w[list])).to be(true) }
      end
    end

    context 'when results directory has a valid session' do
      let(:path) { instance_double(Pathname, :path) }

      let(:raw_expectations) do
        [
          puts_stdout(list_header),
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [path]),
          read_file(path, valid_session_json),
          puts_stdout(list_row)
        ]
      end

      it 'prints header and session row' do
        verify_events { expect(apply(%w[list])).to be(true) }
      end
    end

    context 'when results directory has two sessions prints youngest first' do
      let(:older_id)   { '019cf6f1-0000-0000-0000-000000000000' }
      let(:younger_id) { '019cf6f1-ffff-ffff-ffff-ffffffffffff' }

      let(:older_json) do
        {
          'killtime' => 5.0, 'mutant_version' => '1.0.0', 'pid' => 1,
          'ruby_version' => '4.0.1', 'runtime' => 1.0,
          'session_id' => older_id, 'subject_results' => []
        }.to_json
      end

      let(:younger_json) do
        {
          'killtime' => 6.0, 'mutant_version' => '1.0.0', 'pid' => 2,
          'ruby_version' => '4.0.1', 'runtime' => 1.5,
          'session_id' => younger_id, 'subject_results' => []
        }.to_json
      end

      let(:older_path)   { instance_double(Pathname, :older_path) }
      let(:younger_path) { instance_double(Pathname, :younger_path) }

      let(:older_timestamp)   { '2026-03-16 13:58:35' }
      let(:younger_timestamp) { '2026-03-16 13:59:40' }

      let(:younger_row) do
        '%-6s  %-10s  %-8s  %-10s  %-10s  %-36s  %s' % [0, 0, 0, '1.50s', '6.00s', younger_id, younger_timestamp]
      end

      let(:older_row) do
        '%-6s  %-10s  %-8s  %-10s  %-10s  %-36s  %s' % [0, 0, 0, '1.00s', '5.00s', older_id, older_timestamp]
      end

      let(:raw_expectations) do
        [
          puts_stdout(list_header),
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [older_path, younger_path]),
          read_file(younger_path, younger_json),
          puts_stdout(younger_row),
          read_file(older_path, older_json),
          puts_stdout(older_row)
        ]
      end

      it 'prints youngest session first' do
        verify_events { expect(apply(%w[list])).to be(true) }
      end
    end

    context 'when session has alive mutations shows alive count' do
      let(:path) { instance_double(Pathname, :path) }

      let(:alive_coverage) do
        {
          'mutation_result' => {
            'isolation_result'        => {
              'exception'      => nil,
              'log'            => { 'type' => 'string', 'content' => '' },
              'process_status' => nil,
              'timeout'        => nil,
              'value'          => {
                'job_index' => 0,
                'passed'    => true,
                'runtime'   => 0.1,
                'output'    => { 'type' => 'string', 'content' => '' }
              }
            },
            'mutation_diff'           => "@@ -1 +1 @@\n-true\n+false\n",
            'mutation_identification' => 'evil:Foo#bar:foo.rb:1:abc12',

            'mutation_source'         => 'false',
            'mutation_type'           => 'evil',
            'runtime'                 => 0.1
          },
          'criteria_result' => { 'process_abort' => false, 'test_result' => false, 'timeout' => false }
        }
      end

      let(:session_with_alive_json) do
        {
          'killtime'        => 0.3,
          'mutant_version'  => '1.0.0',
          'pid'             => 12_345,
          'ruby_version'    => '4.0.1',
          'runtime'         => 1.0,
          'session_id'      => session_id,
          'subject_results' => [
            {
              'amount_mutations'  => 2,
              'coverage_results'  => [alive_coverage, alive_coverage],
              'expression_syntax' => 'Foo#bar',
              'identification'    => 'Foo#bar:foo.rb:1',

              'source'            => 'true',
              'source_path'       => 'foo.rb',
              'tests'             => ['test-a']
            },
            {
              'amount_mutations'  => 1,
              'coverage_results'  => [alive_coverage],
              'expression_syntax' => 'Bar#baz',
              'identification'    => 'Bar#baz:bar.rb:1',

              'source'            => 'true',
              'source_path'       => 'bar.rb',
              'tests'             => ['test-b']
            }
          ]
        }.to_json
      end

      let(:alive_row) do
        '%-6s  %-10s  %-8s  %-10s  %-10s  %-36s  %s' % [3, 3, 2, '1.00s', '0.30s', session_id, expected_timestamp]
      end

      let(:raw_expectations) do
        [
          puts_stdout(list_header),
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [path]),
          read_file(path, session_with_alive_json),
          puts_stdout(alive_row)
        ]
      end

      it 'prints alive count' do
        verify_events { expect(apply(%w[list])).to be(true) }
      end
    end

    context 'when results directory has an unparseable session' do
      let(:path) { instance_double(Pathname, :path) }

      let(:unsupported_row) do
        "#{Unparser::Color::RED.format('--------------- [incompatible] ---------------'.ljust(54))}bad-file"
      end

      let(:raw_expectations) do
        [
          puts_stdout(list_header),
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [path]),
          read_file(path, 'not json'),
          {
            receiver:  path,
            selector:  :basename,
            arguments: ['.json'],
            reaction:  { return: Pathname.new('bad-file') }
          },
          puts_stdout(unsupported_row)
        ]
      end

      it 'prints unsupported marker' do
        verify_events { expect(apply(%w[list])).to be(true) }
      end
    end

    context 'with unexpected extra arguments' do
      it 'returns error with exact message' do
        expect(parse(%w[list extra args])).to eql(
          Mutant::Either::Left.new('unexpected arguments: extra args')
        )
      end
    end
  end

  describe 'show' do
    let(:session_path) { instance_double(Pathname, :session_path, to_s: '.mutant/results/test.json') }

    context 'with explicit session ID and valid file' do
      let(:raw_expectations) do
        [
          pathname_new(".mutant/results/#{session_id}.json", session_path),
          { receiver: session_path, selector: :file?, reaction: { return: true } },
          read_file(session_path, valid_session_json),
          puts_stdout("Session:  #{session_id}"),
          puts_stdout("Time:     #{expected_timestamp}"),
          puts_stdout('Version:  1.0.0'),
          puts_stdout('Ruby:     4.0.1'),
          puts_stdout('Subjects: 0'),
          puts_stdout('Alive:    0')
        ]
      end

      it 'prints session metadata' do
        verify_events { expect(apply(['show', '--session-id', session_id])).to be(true) }
      end
    end

    context 'with explicit session ID and alive mutations' do
      # 2 subjects: Baz (covered), Foo (2 alive). Tests reject, flat_map, and alive count.
      let(:session_with_alive_json) do
        <<~'JSON'
          {"killtime":0.3,"mutant_version":"1.0.0","pid":12345,"ruby_version":"4.0.1","runtime":1.0,"session_id":"019cf6f1-77e8-74b6-82db-f8b5faf570cd","subject_results":[{"amount_mutations":1,"coverage_results":[{"mutation_result":{"isolation_result":{"exception":null,"log":{"type":"string","content":""},"process_status":null,"timeout":null,"value":{"job_index":0,"passed":false,"runtime":0.1,"output":{"type":"string","content":""}}},"mutation_diff":"@@ -1 +1 @@\n-true\n+nil\n","mutation_identification":"evil:Baz#qux:baz.rb:1:ghi56","mutation_source":"nil","mutation_type":"evil","runtime":0.1},"criteria_result":{"process_abort":false,"test_result":true,"timeout":false}}],"expression_syntax":"Baz#qux","identification":"Baz#qux:baz.rb:1","source":"true","source_path":"baz.rb","tests":["test-b"]},{"amount_mutations":2,"coverage_results":[{"mutation_result":{"isolation_result":{"exception":null,"log":{"type":"string","content":""},"process_status":null,"timeout":null,"value":{"job_index":0,"passed":true,"runtime":0.1,"output":{"type":"string","content":""}}},"mutation_diff":"@@ -1 +1 @@\n-true\n+false\n","mutation_identification":"evil:Foo#bar:foo.rb:1:abc12","mutation_source":"false","mutation_type":"evil","runtime":0.1},"criteria_result":{"process_abort":false,"test_result":false,"timeout":false}},{"mutation_result":{"isolation_result":{"exception":null,"log":{"type":"string","content":""},"process_status":null,"timeout":null,"value":{"job_index":0,"passed":true,"runtime":0.1,"output":{"type":"string","content":""}}},"mutation_diff":"@@ -1 +1 @@\n-true\n+nil\n","mutation_identification":"evil:Foo#bar:foo.rb:1:def34","mutation_source":"false","mutation_type":"evil","runtime":0.1},"criteria_result":{"process_abort":false,"test_result":false,"timeout":false}}],"expression_syntax":"Foo#bar","identification":"Foo#bar:foo.rb:1","source":"true","source_path":"foo.rb","tests":["test-a"]}]}
        JSON
      end

      let(:raw_expectations) do
        [
          pathname_new(".mutant/results/#{session_id}.json", session_path),
          { receiver: session_path, selector: :file?, reaction: { return: true } },
          read_file(session_path, session_with_alive_json),
          puts_stdout("Session:  #{session_id}"),
          puts_stdout("Time:     #{expected_timestamp}"),
          puts_stdout('Version:  1.0.0'),
          puts_stdout('Ruby:     4.0.1'),
          puts_stdout('Subjects: 2'),
          puts_stdout('Alive:    2'),

          puts_stdout('Foo#bar:foo.rb:1'),
          puts_stdout('tests: 1, runtime: 0.20s, killtime: 0.20s'),
          puts_stdout('evil:Foo#bar:foo.rb:1:abc12'),
          puts_stdout('-----------------------'),
          {
            receiver:  stdout,
            selector:  :write,
            arguments: ["@@ -1 +1 @@\n-true\n+false\n"]
          },
          puts_stdout('-----------------------'),
          puts_stdout('evil:Foo#bar:foo.rb:1:def34'),
          puts_stdout('-----------------------'),
          {
            receiver:  stdout,
            selector:  :write,
            arguments: ["@@ -1 +1 @@\n-true\n+nil\n"]
          },
          puts_stdout('-----------------------'),
          puts_stdout('selected tests (1):'),
          puts_stdout('- test-a')
        ]
      end

      it 'prints session report with alive mutations' do
        verify_events { expect(apply(['show', '--session-id', session_id])).to be(true) }
      end
    end

    context 'with explicit session ID and missing file' do
      let(:raw_expectations) do
        [
          pathname_new(".mutant/results/#{session_id}.json", session_path),
          { receiver: session_path, selector: :file?, reaction: { return: false } },
          puts_stderr('Session file not found: .mutant/results/test.json')
        ]
      end

      it 'returns false' do
        verify_events { expect(apply(['show', '--session-id', session_id])).to be(false) }
      end
    end

    context 'with explicit session ID and invalid JSON' do
      let(:raw_expectations) do
        [
          pathname_new(".mutant/results/#{session_id}.json", session_path),
          { receiver: session_path, selector: :file?, reaction: { return: true } },
          read_file(session_path, 'not json'),
          puts_stderr(
            "Failed to load session: unexpected token 'not' at line 1 column 1\n" \
            'Run `mutant session gc` to remove incompatible sessions.'
          )
        ]
      end

      it 'returns false' do
        verify_events { expect(apply(['show', '--session-id', session_id])).to be(false) }
      end
    end

    context 'without session ID defaults to latest' do
      let(:older_path) { instance_double(Pathname, :older_path) }
      let(:latest_path) { instance_double(Pathname, :latest_path) }

      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [older_path, latest_path]),
          { receiver: latest_path, selector: :file?, reaction: { return: true } },
          read_file(latest_path, valid_session_json),
          puts_stdout("Session:  #{session_id}"),
          puts_stdout("Time:     #{expected_timestamp}"),
          puts_stdout('Version:  1.0.0'),
          puts_stdout('Ruby:     4.0.1'),
          puts_stdout('Subjects: 0'),
          puts_stdout('Alive:    0')
        ]
      end

      it 'prints session report from latest file' do
        verify_events { expect(apply(%w[show])).to be(true) }
      end
    end

    context 'with unexpected arguments' do
      it 'returns error with exact message' do
        expect(parse(%w[show extra])).to eql(
          Mutant::Either::Left.new('unexpected arguments: extra')
        )
      end
    end

    context 'with invalid session ID format' do
      it 'returns error' do
        result = parse(%w[show --session-id not-a-uuid])
        expect(result).to be_a(Mutant::Either::Left)
        expect(result.from_left).to include('invalid UUID format: not-a-uuid')
      end
    end

    context '--help' do
      let(:expected_help) do
        <<~HELP
          usage: mutant session show [options]

          Summary: Show results of a past session

          mutant version: #{Mutant::VERSION}

          Global Options:

                  --help                       Print help
                  --version                    Print mutants version
                  --profile                    Profile mutant execution
                  --zombie                     Run mutant zombified


                  --session-id=ID              Session ID to operate on (default: latest)



          Display Options:

                  --verbose                    Show verbose output
        HELP
      end

      let(:raw_expectations) do
        [
          puts_stdout(expected_help)
        ]
      end

      it 'prints help with session-id option' do
        verify_events { expect(apply(%w[show --help])).to be(true) }
      end
    end

    context 'without session ID and latest file is corrupt' do
      let(:latest_path) { instance_double(Pathname, :latest_path) }

      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [latest_path]),
          { receiver: latest_path, selector: :file?, reaction: { return: true } },
          read_file(latest_path, 'not json'),
          puts_stderr(
            "Failed to load session: unexpected token 'not' at line 1 column 1\n" \
            'Run `mutant session gc` to remove incompatible sessions.'
          )
        ]
      end

      it 'returns false with load error' do
        verify_events { expect(apply(%w[show])).to be(false) }
      end
    end

    context 'without session ID and no sessions exist' do
      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, false),
          puts_stderr('No sessions found')
        ]
      end

      it 'returns false' do
        verify_events { expect(apply(%w[show])).to be(false) }
      end
    end
  end

  describe 'subject' do
    let(:path) { instance_double(Pathname, :path) }

    let(:alive_coverage) do
      {
        'mutation_result' => {
          'isolation_result'        => {
            'exception'      => nil,
            'log'            => { 'type' => 'string', 'content' => '' },
            'process_status' => nil,
            'timeout'        => nil,
            'value'          => {
              'job_index' => 0,
              'passed'    => true,
              'runtime'   => 0.1,
              'output'    => { 'type' => 'string', 'content' => '' }
            }
          },
          'mutation_diff'           => "@@ -1 +1 @@\n-true\n+false\n",
          'mutation_identification' => 'evil:Bar#baz:bar.rb:1:abc12',
          'mutation_source'         => 'false',
          'mutation_type'           => 'evil',
          'runtime'                 => 0.1
        },
        'criteria_result' => { 'process_abort' => false, 'test_result' => false, 'timeout' => false }
      }
    end

    let(:session_with_subjects_json) do
      {
        'killtime'        => 0.1,
        'mutant_version'  => '1.0.0',
        'pid'             => 12_345,
        'ruby_version'    => '4.0.1',
        'runtime'         => 0.5,
        'session_id'      => session_id,
        'subject_results' => [
          {
            'amount_mutations'  => 1,
            'coverage_results'  => [],
            'expression_syntax' => 'Foo#bar',
            'identification'    => 'Foo#bar:foo.rb:1',

            'source'            => 'true',
            'source_path'       => 'foo.rb',
            'tests'             => ['test-a']
          },
          {
            'amount_mutations'  => 1,
            'coverage_results'  => [alive_coverage],
            'expression_syntax' => 'Bar#baz',
            'identification'    => 'Bar#baz:bar.rb:1',

            'source'            => 'true',
            'source_path'       => 'bar.rb',
            'tests'             => ['test-b']
          }
        ]
      }.to_json
    end

    context 'without expression lists all subjects' do
      let(:subjects_header) { '%-6s  %-6s  %s' % %w[ALIVE TOTAL SUBJECT] }
      let(:bar_row)         { '%-6s  %-6s  %s' % [1, 1, 'Bar#baz'] }
      let(:foo_row)         { '%-6s  %-6s  %s' % [0, 1, 'Foo#bar'] }

      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [path]),
          { receiver: path, selector: :file?, reaction: { return: true } },
          read_file(path, session_with_subjects_json),
          puts_stdout("Session:  #{session_id}"),
          puts_stdout(subjects_header),
          puts_stdout(bar_row),
          puts_stdout(foo_row)
        ]
      end

      it 'prints subjects sorted by alive count descending' do
        verify_events { expect(apply(%w[subject])).to be(true) }
      end
    end

    context 'with expression shows subject detail' do
      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [path]),
          { receiver: path, selector: :file?, reaction: { return: true } },
          read_file(path, session_with_subjects_json),
          puts_stdout("Session:  #{session_id}"),

          puts_stdout('Bar#baz:bar.rb:1'),
          puts_stdout('tests: 1, runtime: 0.10s, killtime: 0.10s'),
          puts_stdout('evil:Bar#baz:bar.rb:1:abc12'),
          puts_stdout('-----------------------'),
          {
            receiver:  stdout,
            selector:  :write,
            arguments: ["@@ -1 +1 @@\n-true\n+false\n"]
          },
          puts_stdout('-----------------------'),
          puts_stdout('selected tests (1):'),
          puts_stdout('- test-b')
        ]
      end

      it 'prints alive mutations for the subject' do
        verify_events { expect(apply(%w[subject Bar#baz])).to be(true) }
      end
    end

    context 'with expression and --verbose shows isolation logs' do
      let(:verbose_coverage) do
        {
          'mutation_result' => {
            'isolation_result'        => {
              'exception'      => nil,
              'log'            => { 'type' => 'string', 'content' => '' },
              'timeout'        => nil,
              'process_status' => { 'exitstatus' => 0 },
              'value'          => {
                'job_index' => 0,
                'passed'    => true,
                'runtime'   => 0.1,
                'output'    => { 'type' => 'string', 'content' => '' }
              }
            },
            'mutation_diff'           => "@@ -1 +1 @@\n-true\n+false\n",
            'mutation_identification' => 'evil:Qux#quux:qux.rb:1:abc12',

            'mutation_source'         => 'false',
            'mutation_type'           => 'evil',
            'runtime'                 => 0.1
          },
          'criteria_result' => { 'process_abort' => false, 'test_result' => false, 'timeout' => false }
        }
      end

      let(:verbose_session_json) do
        {
          'killtime'        => 0.1,
          'mutant_version'  => '1.0.0',
          'pid'             => 12_345,
          'ruby_version'    => '4.0.1',
          'runtime'         => 0.5,
          'session_id'      => session_id,
          'subject_results' => [
            {
              'amount_mutations'  => 1,
              'coverage_results'  => [verbose_coverage],
              'expression_syntax' => 'Qux#quux',
              'identification'    => 'Qux#quux:qux.rb:1',

              'source'            => 'true',
              'source_path'       => 'qux.rb',
              'tests'             => ['test-c']
            }
          ]
        }.to_json
      end

      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [path]),
          { receiver: path, selector: :file?, reaction: { return: true } },
          read_file(path, verbose_session_json),
          puts_stdout("Session:  #{session_id}"),

          puts_stdout('Qux#quux:qux.rb:1'),
          puts_stdout('tests: 1, runtime: 0.10s, killtime: 0.10s'),
          puts_stdout('evil:Qux#quux:qux.rb:1:abc12'),
          puts_stdout('-----------------------'),
          puts_stdout('Killfork: #<Mutant::Result::ProcessStatus exitstatus=0>'),
          {
            receiver:  stdout,
            selector:  :write,
            arguments: ["@@ -1 +1 @@\n-true\n+false\n"]
          },
          puts_stdout('-----------------------'),
          puts_stdout('selected tests (1):'),
          puts_stdout('- test-c')
        ]
      end

      it 'prints alive mutations with isolation logs' do
        verify_events { expect(apply(%w[subject --verbose Qux#quux])).to be(true) }
      end
    end

    context 'with unknown expression' do
      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [path]),
          { receiver: path, selector: :file?, reaction: { return: true } },
          read_file(path, session_with_subjects_json),
          puts_stdout("Session:  #{session_id}"),
          puts_stderr('Subject not found: Unknown#method')
        ]
      end

      it 'returns false' do
        verify_events { expect(apply(%w[subject Unknown#method])).to be(false) }
      end
    end

    context 'with too many arguments' do
      it 'returns error' do
        expect(parse(%w[subject Foo#bar extra])).to eql(
          Mutant::Either::Left.new('Expected zero or one subject expression argument')
        )
      end
    end
  end

  describe 'gc --help' do
    let(:expected_help) do
      <<~HELP
        usage: mutant session gc [options]

        Summary: Remove incompatible and old session results

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified


                --keep=N                     Keep N most recent sessions (default: 100)
      HELP
    end

    let(:raw_expectations) do
      [
        puts_stdout(expected_help)
      ]
    end

    it 'prints help with default keep value' do
      verify_events { expect(apply(%w[gc --help])).to be(true) }
    end
  end

  describe 'gc' do
    context 'with no sessions' do
      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, false),
          puts_stdout('Removed 0 session(s)')
        ]
      end

      it 'reports zero removed' do
        verify_events { expect(apply(%w[gc])).to be(true) }
      end
    end

    context 'with incompatible sessions' do
      let(:bad_path)  { instance_double(Pathname, :bad)  }
      let(:good_path) { instance_double(Pathname, :good) }

      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', [bad_path, good_path]),
          read_file(bad_path, 'not json'),
          read_file(good_path, valid_session_json),
          { receiver: bad_path, selector: :delete },
          puts_stdout('Removed 1 session(s)')
        ]
      end

      it 'removes incompatible sessions' do
        verify_events { expect(apply(%w[gc])).to be(true) }
      end
    end

    context 'with compatible sessions within keep limit' do
      let(:paths) do
        2.times.map { |i| instance_double(Pathname, "path_#{i}") }
      end

      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', paths),
          *paths.map { |path| read_file(path, valid_session_json) },
          puts_stdout('Removed 0 session(s)')
        ]
      end

      it 'removes nothing' do
        verify_events { expect(apply(%w[gc --keep=5])).to be(true) }
      end
    end

    context 'with excess compatible sessions' do
      let(:paths) do
        4.times.map { |i| instance_double(Pathname, "path_#{i}") }
      end

      let(:raw_expectations) do
        [
          pathname_new('.mutant/results', results_dir),
          directory_check(results_dir, true),
          glob(results_dir, '*.json', paths),
          *paths.map { |path| read_file(path, valid_session_json) },
          { receiver: paths[0], selector: :delete },
          { receiver: paths[1], selector: :delete },
          { receiver: paths[2], selector: :delete },
          puts_stdout('Removed 3 session(s)')
        ]
      end

      it 'removes oldest beyond keep limit' do
        verify_events { expect(apply(%w[gc --keep=1])).to be(true) }
      end
    end
  end
end
# rubocop:enable Style/FormatStringToken
