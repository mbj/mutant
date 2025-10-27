# frozen_string_literal: true

module Mutant
  module MCP
    # MCP Resource provider
    module Resources
      # Build list of available resources
      #
      # @return [Array<::MCP::Resource>]
      def self.build
        [
          version_resource,
          config_resource
        ]
      end

      # Read resource contents by URI
      #
      # @param uri [String]
      # @param cli_config [Config]
      # @param world [World]
      #
      # @return [Array<::MCP::Resource::TextContents>]
      def self.read(uri:, cli_config:, world:)
        case uri
        when 'mutant://version'
          [read_version(world:)]
        when 'mutant://config'
          [read_config(cli_config:, world:)]
        else
          []
        end
      end

      # Version resource
      #
      # @return [::MCP::Resource]
      def self.version_resource
        ::MCP::Resource.new(
          uri:         'mutant://version',
          name:        'Mutant Version',
          description: 'Mutant version and Ruby environment information',
          mime_type:   'application/json'
        )
      end
      private_class_method :version_resource

      # Config resource
      #
      # @return [::MCP::Resource]
      def self.config_resource
        ::MCP::Resource.new(
          uri:         'mutant://config',
          name:        'Mutant Configuration',
          description: 'Loaded mutant configuration (file + env)',
          mime_type:   'application/json'
        )
      end
      private_class_method :config_resource

      # Read version resource contents
      #
      # @param world [World]
      #
      # @return [::MCP::Resource::TextContents]
      def self.read_version(world:)
        content = {
          version:      VERSION,
          ruby_version: RUBY_VERSION,
          platform:     RUBY_PLATFORM
        }

        ::MCP::Resource::TextContents.new(
          uri:       'mutant://version',
          mime_type: 'application/json',
          text:      world.json.pretty_generate(content)
        )
      end
      private_class_method :read_version

      # Read config resource contents
      #
      # @param cli_config [Config]
      # @param world [World]
      #
      # @return [::MCP::Resource::TextContents]
      def self.read_config(cli_config:, world:)
        config_result = Config.load(cli_config:, world:)

        content = config_result.either(
          ->(error) { { error: } },
          ->(config) { config.to_h }
        )

        ::MCP::Resource::TextContents.new(
          uri:       'mutant://config',
          mime_type: 'application/json',
          text:      world.json.pretty_generate(content)
        )
      end
      private_class_method :read_config
    end # Resources
  end # MCP
end # Mutant
