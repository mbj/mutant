module Mutant
  class Reporter
    class CLI
      # Interface to the optionally present tput binary
      class Tput
        include Adamantium, Concord::Public.new(:prepare, :restore)

        private_class_method :new

        # Detected tput support
        #
        # @return [Tput]
        #   if tput support is present
        #
        # @return [nil]
        #   otherwise
        def self.detect
          reset   = capture('tput reset')
          save    = capture('tput sc') if reset
          restore = capture('tput rc') if save
          clean   = capture('tput ed') || capture('tput cd') if restore
          new(reset + save, restore + clean) if clean
        end

        # Capture output
        #
        # @param [String] command
        #   command to run
        #
        # @return [String]
        #   stdout of command on success
        #
        # @return [nil]
        #   otherwise
        def self.capture(command)
          stdout, _stderr, exitstatus = Open3.capture3(command)
          stdout if exitstatus.success?
        end
        private_class_method :capture

      end # Tput
    end # CLI
  end # Reporter
end # Mutant
