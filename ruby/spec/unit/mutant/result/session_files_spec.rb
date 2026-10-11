# frozen_string_literal: true

RSpec.describe Mutant::Result::SessionFiles do
  let(:dir)      { instance_double(Pathname, :dir)            }
  let(:pathname) { class_double(Pathname)                     }
  let(:world)    { instance_double(Mutant::World, pathname:)  }
  let(:object)   { described_class.new(world:)                }

  let(:paths) do
    Array.new(4) { |index| instance_double(Pathname, "path_#{index}") }
  end

  before do
    allow(pathname).to receive(:new).with('.mutant/results').and_return(dir)
  end

  describe '#paths' do
    context 'when the results directory does not exist' do
      before do
        allow(dir).to receive(:directory?).and_return(false)
      end

      it 'returns no paths' do
        expect(object.paths).to be(Mutant::EMPTY_ARRAY)
      end
    end

    context 'when the results directory exists' do
      before do
        allow(dir).to receive_messages(directory?: true)
        allow(dir).to receive(:glob).with('*.json{,.gz}').and_return(paths)
      end

      it 'returns the plain and compressed session files' do
        expect(object.paths).to be(paths)
      end
    end
  end

  describe '#prune' do
    before do
      allow(dir).to receive_messages(directory?: true)
      allow(dir).to receive(:glob).with('*.json{,.gz}').and_return(paths)
      paths.each { |path| allow(path).to receive(:delete) }
    end

    it 'deletes all but the most recent sessions' do
      object.prune(2)

      paths.first(2).each { |path| expect(path).to have_received(:delete) }
      paths.last(2).each { |path| expect(path).not_to have_received(:delete) }
    end

    it 'returns the deleted sessions' do
      expect(object.prune(2)).to eql([paths[1], paths[0]])
    end

    it 'deletes nothing with no more sessions than it keeps' do
      expect(object.prune(4)).to eql([])

      paths.each { |path| expect(path).not_to have_received(:delete) }
    end

    # A concurrent run may prune the same sessions
    context 'when a session was deleted already' do
      before do
        allow(paths[1]).to receive(:delete).and_raise(Errno::ENOENT)
      end

      it 'deletes the rest' do
        object.prune(1)

        expect(paths[0]).to have_received(:delete)
        expect(paths[2]).to have_received(:delete)
      end
    end
  end
end
