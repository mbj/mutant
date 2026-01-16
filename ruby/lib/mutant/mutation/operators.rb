# frozen_string_literal: true

module Mutant
  # Represent a mutated node with its subject
  class Mutation
    class Operators
      include Equalizer.new

      class Full < self
        NAME = :full

        SELECTOR_REPLACEMENTS = {
          :& =>          %i[| ^],
          :< =>          %i[== eql? equal?],
          :<< =>         %i[>>],
          :<= =>         %i[< == eql? equal?],
          :== =>         %i[eql? equal?],
          :=== =>        %i[is_a?],
          :=~ =>         %i[match?],
          :> =>          %i[== eql? equal?],
          :>= =>         %i[> == eql? equal?],
          :>> =>         %i[<<],
          :^ =>          %i[& |],
          :| =>          %i[& ^],
          __send__:      %i[public_send],
          all?:          %i[any?],
          any?:          %i[all?],
          at:            %i[fetch key?],
          detect:        %i[first last],
          fetch:         %i[key?],
          find:          %i[first last],
          first:         %i[last],
          flat_map:      %i[map],
          gsub:          %i[sub],
          is_a?:         %i[instance_of?],
          kind_of?:      %i[instance_of?],
          last:          %i[first],
          map:           %i[each],
          match:         %i[match?],
          max:           %i[first last],
          max_by:        %i[first last],
          method:        %i[public_method],
          min:           %i[first last],
          min_by:        %i[first last],
          reverse_each:  %i[each],
          reverse_map:   %i[map each],
          reverse_merge: %i[merge],
          send:          %i[public_send __send__],
          to_a:          %i[to_ary],
          to_h:          %i[to_hash],
          to_i:          %i[to_int],
          to_s:          %i[to_str],
          values_at:     %i[fetch_values]
        }.freeze.tap { |hash| hash.each_value(&:freeze) }
      end

      class Light < self
        NAME = :light

        SELECTOR_REPLACEMENTS = Full::SELECTOR_REPLACEMENTS
          .dup
          .tap do |replacements|
            replacements.delete(:==)
            replacements.delete(:eql?)
            replacements.delete(:first)
            replacements.delete(:last)
          end
          .freeze
      end

      def self.operators_name
        self::NAME
      end

      def selector_replacements
        self.class::SELECTOR_REPLACEMENTS
      end

      def self.parse(value)
        klass = [Light, Full].detect { |candidate| candidate.operators_name.to_s.eql?(value) }

        if klass
          Either::Right.new(klass.new)
        else
          Either::Left.new("Unknown operators: #{value}")
        end
      end

      TRANSFORM =
        Transform::Sequence.new(
          steps: [
            Transform::STRING,
            Transform::Block.capture('parse operator', &method(:parse))
          ]
        )
    end # Operators
  end # Mutation
end # Mutant
