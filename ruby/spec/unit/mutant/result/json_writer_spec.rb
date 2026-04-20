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
    instance_double(Mutant::Result::Env, killtime: 10.5, runtime: 2.5, subject_results: [])
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
        expect(data.fetch('killtime')).to eql(10.5)
        expect(data.fetch('runtime')).to eql(2.5)
        expect(data.fetch('subject_results')).to eql([])
      end
    end

    it 'returns the path' do
      expect(object.call).to be(path)
    end
  end

  describe '#json' do
    before { allow(process).to receive(:pid).and_return(42) }

    it 'scrubs encoding of the dumped session before JSON generation' do
      dumped = { 'ruby_version' => "bad\xF7byte".b }
      allow(Mutant::Result::Session::JSON)
        .to receive(:dump)
        .with(instance_of(Mutant::Result::Session))
        .and_return(Mutant::Either::Right.new(dumped))

      expect(JSON.parse(object.__send__(:json)))
        .to eql('ruby_version' => "bad\uFFFDbyte")
    end
  end

  describe '#scrub_encoding' do
    def scrub(value)
      object.__send__(:scrub_encoding, value)
    end

    it 'retags ASCII-8BIT strings holding valid UTF-8 bytes as UTF-8' do
      binary = (+'hellö').force_encoding(Encoding::ASCII_8BIT)
      result = scrub(binary)

      expect(result.encoding).to be(Encoding::UTF_8)
      expect(result).to eql('hellö')
    end

    it 'replaces invalid UTF-8 byte sequences with the replacement character' do
      expect(scrub("bad\xF7byte".b)).to eql("bad\uFFFDbyte")
    end

    it 'does not mutate frozen strings' do
      frozen = 'frozen'.b.freeze

      expect { scrub(frozen) }.not_to raise_error
      expect(frozen.encoding).to be(Encoding::ASCII_8BIT)
    end

    it 'recurses into hash values' do
      expect(scrub('key' => "bad\xF7".b)).to eql('key' => "bad\uFFFD")
    end

    it 'recurses into array elements' do
      expect(scrub(["bad\xF7".b, 'ok'])).to eql(["bad\uFFFD", 'ok'])
    end

    it 'leaves non-string scalars untouched' do
      expect(scrub(42)).to be(42)
      expect(scrub(nil)).to be(nil)
    end
  end
end
