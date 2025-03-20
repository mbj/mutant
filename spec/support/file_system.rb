# frozen_string_literal: true

module MutantSpec
  class FileState
    DEFAULTS = {
      file:     false,
      contents: nil,
      requires: [].freeze
    }.freeze

    include Adamantium, Anima.new(*DEFAULTS.keys)

    def self.new(attributes = DEFAULTS)
      super(DEFAULTS.merge(attributes))
    end

    DOES_NOT_EXIST = new

    alias_method :file?, :file
  end # FileState

  class FakePathname
    include Adamantium, Anima.new(:file_system, :pathname)

    def join(*)
      self.class.new(
        file_system:,
        pathname:    pathname.join(*)
      )
    end

    def read
      state.contents
    end

    def to_s
      pathname.to_s
    end

    def file?
      state.file?
    end

  private

    def state
      file_system.state(pathname.to_s)
    end
  end # FakePathname

  class FileSystem
    include Adamantium, Anima.new(:file_states)

    def state(filename)
      file_states.fetch(filename, FileState::DOES_NOT_EXIST)
    end

    def path(filename)
      FakePathname.new(file_system: self, pathname: Pathname.new(filename))
    end
  end # FileSystem
end # MutantSpec
