# frozen_string_literal: true

module Mutant
  class Segment
    include Adamantium, Anima.new(
      :id,
      :name,
      :parent_id,
      :timestamp_end,
      :timestamp_start
    )

    def elapsed = timestamp_end - timestamp_start

    def offset_start(recording_start)
      timestamp_start - recording_start
    end

    def offset_end(recording_start)
      timestamp_end - recording_start
    end
  end # Segment
end # Mutant
