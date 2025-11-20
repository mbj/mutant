# frozen_string_literal: true

module Mutant
  class Segment
    class Recorder
      include Anima.new(
        :gen_id,
        :parent_id,
        :recording_start,
        :root_id,
        :segments,
        :timer
      )

      private(*anima.attribute_names)

      # rubocop:disable Metrics/MethodLength
      def record(name)
        start     = timer.now
        parent_id = parent_id()

        @parent_id = id = gen_id.call

        yield.tap do
          segments << Segment.new(
            id:,
            name:,
            parent_id:,
            timestamp_end:   timer.now,
            timestamp_start: start
          )
        end
      ensure
        @parent_id = parent_id
      end
      # rubocop:enable Metrics/MethodLength

      def print_profile(io)
        print_node(io, tree, 0)
      end

    private

      class Node
        include Adamantium, Anima.new(:value, :children)
      end
      private_constant :Node

      def tree
        id_index     = {}
        parent_index = {}

        final_segments.each do |segment|
          id_index[segment.id] = segment

          (parent_index[segment.parent_id] ||= []) << segment
        end

        build_node(
          value:        id_index.fetch(root_id),
          parent_index:
        )
      end

      def final_segments
        timestamp_end = timer.now

        segments.map do |segment|
          if segment.timestamp_end
            segment
          else
            segment.with(timestamp_end:)
          end
        end
      end

      def build_node(value:, parent_index:)
        Node.new(
          value:,
          children: build_children(
            parent_id:    value.id,
            parent_index:
          )
        )
      end

      def build_children(parent_id:, parent_index:)
        parent_index
          .fetch(parent_id, EMPTY_ARRAY)
          .map { |value| build_node(value:, parent_index:) }
      end

      def print_node(io, node, indent)
        segment = node.value

        indent_str = '  ' * indent

        print_line(io, :offset_start, segment, indent_str)

        return unless node.children.any?

        node.children.each do |child|
          print_node(io, child, indent.succ)
        end
        print_line(io, :offset_end, segment, indent_str)
      end

      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Style/FormatStringToken
      def print_line(io, offset, segment, indent_str)
        io.puts(
          '%4.4f: (%4.4fs) %s %s' % [
            segment.public_send(offset, recording_start),
            segment.elapsed,
            indent_str,
            segment.name
          ]
        )
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Style/FormatStringToken
    end # Recorder
  end # Segment
end # Mutant
