# frozen_string_literal: true

RSpec.describe Mutant::Result::JSONWriter do
  let(:dir)       { instance_double(Pathname, :dir) }
  let(:path)      { instance_double(Pathname, :path) }
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
    instance_double(Mutant::Result::Env, subject_results: [])
  end

  let(:object) { described_class.new(env:, result:) }

  describe '#call' do
    before do
      allow(pathname).to receive(:new).with('.mutant/results').and_return(dir)
      allow(dir).to receive(:mkpath)
      allow(dir).to receive(:join).with("#{Mutant::SESSION_ID}.json").and_return(path)
      allow(path).to receive(:write)
      allow(process).to receive(:pid).and_return(42)
    end

    it 'creates the results directory' do
      object.call

      expect(dir).to have_received(:mkpath)
    end

    it 'writes JSON to the session file' do
      object.call

      expect(path).to have_received(:write) do |json|
        data = JSON.parse(json)

        expect(data.fetch('session_id')).to eql(Mutant::SESSION_ID)
        expect(data.fetch('mutant_version')).to eql(Mutant::VERSION)
        expect(data.fetch('ruby_version')).to eql(RUBY_VERSION)
        expect(data.fetch('pid')).to eql(42)
        expect(data.fetch('subject_results')).to eql([])
      end
    end

    it 'returns the path' do
      expect(object.call).to be(path)
    end
  end
end
