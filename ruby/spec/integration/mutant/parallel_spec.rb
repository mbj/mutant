# frozen_string_literal: true

RSpec.describe 'parallel', mutant: false do
  let(:sink_class) do
    Class.new do
      include Mutant::Parallel::Sink

      def initialize
        @responses = []
      end

      def response(response)
        @responses << response
      end

      def stop?
        false
      end

      def status
        @responses
      end
    end
  end

  specify 'trivial' do
    sink = sink_class.new

    config = Mutant::Parallel::Config.new(
      block:            ->(value) { puts("Payload: #{value}"); value * 2 },
      jobs:             1,
      on_process_start: ->(index:) { puts("Booting: #{index}") },
      process_name:     'test-parallel-process',
      sink:,
      source:           Mutant::Parallel::Source::Array.new(jobs: [1, 2, 3]),
      thread_name:      'test-parallel-thread',
      timeout:          1.0
    )

    driver = Mutant::Parallel.async(
      config:,
      world:  Mutant::WORLD
    )

    loop do
      status = driver.wait_timeout(0.1)
      break if status.done?
    end

    expect(sink.status).to eql(
      [
        Mutant::Parallel::Response.new(
          error:  nil,
          job:    Mutant::Parallel::Source::Job.new(index: 0, payload: 1),
          log:    "Booting: 0\nPayload: 1\n",
          result: 2
        ),
        Mutant::Parallel::Response.new(
          error:  nil,
          job:    Mutant::Parallel::Source::Job.new(index: 1, payload: 2),
          log:    "Payload: 2\n",
          result: 4
        ),
        Mutant::Parallel::Response.new(
          error:  nil,
          job:    Mutant::Parallel::Source::Job.new(index: 2, payload: 3),
          log:    "Payload: 3\n",
          result: 6
        )
      ]
    )
  end

  specify 'crashing' do
    sink = sink_class.new

    config = Mutant::Parallel::Config.new(
      block:            ->(value) { fail if value.equal?(2) },
      jobs:             1,
      on_process_start: ->(index:) {},
      process_name:     'test-parallel-process',
      sink:,
      source:           Mutant::Parallel::Source::Array.new(jobs: [1, 2, 3]),
      thread_name:      'test-parallel-thread',
      timeout:          1.0
    )

    driver = Mutant::Parallel.async(
      config:,
      world:  Mutant::WORLD
    )

    loop do
      status = driver.wait_timeout(0.1)
      break if status.done?
    end

    responses = sink.status

    expect(responses.length).to be(2)

    response_a, response_b = responses

    expect(response_a).to eql(
      Mutant::Parallel::Response.new(
        error:  nil,
        job:    Mutant::Parallel::Source::Job.new(index: 0, payload: 1),
        log:    '',
        result: nil
      )
    )
    expect(response_b.error).to be(EOFError)
    expect(response_b.result).to be(nil)
    expect(response_b.log.match?('<main>')).to be(true)
  end

  specify 'massive' do
    b = '#' * (1024**2) * 10

    sink = sink_class.new

    config = Mutant::Parallel::Config.new(
      block:            ->(value) { (b * value).tap(&method(:puts)) },
      jobs:             1,
      on_process_start: ->(_) { puts b },
      process_name:     'test-parallel-process',
      sink:,
      source:           Mutant::Parallel::Source::Array.new(jobs: [1, 2]),
      thread_name:      'test-parallel-thread',
      timeout:          1.0
    )

    driver = Mutant::Parallel.async(
      config:,
      world:  Mutant::WORLD
    )

    loop do
      status = driver.wait_timeout(0.1)
      break if status.done?
    end

    expect(sink.status).to eql(
      [
        Mutant::Parallel::Response.new(
          error:  nil,
          job:    Mutant::Parallel::Source::Job.new(index: 0, payload: 1),
          log:    "#{b}\n#{b}\n",
          result: b
        ),
        Mutant::Parallel::Response.new(
          error:  nil,
          job:    Mutant::Parallel::Source::Job.new(index: 1, payload: 2),
          log:    "#{b}#{b}\n",
          result: b * 2
        )
      ]
    )
  end

  specify 'chatty' do
    sink = sink_class.new

    config = Mutant::Parallel::Config.new(
      block:            ->(value) { value },
      jobs:             1,
      on_process_start: ->(_) { Thread.start { i = 0; loop { puts("<iteration #{i += 1}>"); } } },
      process_name:     'test-parallel-process',
      sink:,
      source:           Mutant::Parallel::Source::Array.new(jobs: [1, 2, 3]),
      thread_name:      'test-parallel-thread',
      timeout:          1.0
    )

    driver = Mutant::Parallel.async(
      config:,
      world:  Mutant::WORLD
    )

    loop do
      status = driver.wait_timeout(0.1)
      break if status.done?
    end

    responses = sink.status

    expect(responses.length).to be(3)

    responses.each do |response|
      expect(response.log.match?(/<iteration \d+>/)).to be(true)
    end
  end

  specify 'many' do
    sink = sink_class.new

    config = Mutant::Parallel::Config.new(
      block:            ->(value) { value },
      jobs:             Etc.nprocessors,
      on_process_start: ->(index:) {},
      process_name:     'test-parallel-process',
      sink:,
      source:           Mutant::Parallel::Source::Array.new(jobs: Array.new(1000) { |value| value }),
      thread_name:      'test-parallel-thread',
      timeout:          1.0
    )

    driver = Mutant::Parallel.async(
      config:,
      world:  Mutant::WORLD
    )

    loop do
      status = driver.wait_timeout(0.1)
      break if status.done?
    end

    expect(sink.status.length).to be(1000)
  end

  specify 'stuck' do
    sink = sink_class.new

    config = Mutant::Parallel::Config.new(
      block:            ->(_value) { sleep },
      jobs:             1,
      on_process_start: ->(index:) {},
      process_name:     'test-parallel-process',
      sink:,
      source:           Mutant::Parallel::Source::Array.new(jobs: [1]),
      thread_name:      'test-parallel-thread',
      timeout:          1.0
    )

    driver = Mutant::Parallel.async(
      config:,
      world:  Mutant::WORLD
    )

    loop do
      status = driver.wait_timeout(0.1)
      break if status.done?
    end

    expect(sink.status).to eql(
      [
        Mutant::Parallel::Response.new(
          error:  Timeout::Error,
          job:    Mutant::Parallel::Source::Job.new(index: 0, payload: 1),
          log:    '',
          result: nil
        )
      ]
    )
  end
end
