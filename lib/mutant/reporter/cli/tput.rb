module Mutant
  class Reporter
    class CLI
      # Interface to the optionally present tput binary
      class Tput
        include Adamantium, Concord::Public.new(:available, :prepare, :restore)

        private_class_method :new

        capture = lambda do |command|
          stdout, _stderr, exitstatus = Open3.capture3(command)
          stdout if exitstatus.success?
        end

        reset   = capture.('tput reset')
        save    = capture.('tput sc') if reset
        restore = capture.('tput rc') if save
        clean   = capture.('tput ed') if restore

        UNAVAILABLE = new(false, nil, nil)

        INSTANCE =
          if save && restore && clean
            new(true, reset + save, restore + clean)
          else
            UNAVAILABLE
          end

      end # TPUT
    end # CLI
  end # Reporter
end # Mutant
