# frozen_string_literal: true

module Mutant
  # Represent a mutated node with its subject
  class Mutation
    class Operators
      include Equalizer.new

      class Full < self
        NAME = :full

        SELECTOR_REPLACEMENTS = {
          :!= =>              %i[==],
          :** =>              %i[*],
          :% =>               %i[/],
          :& =>               %i[| ^],
          :* =>               %i[/],
          :+ =>               %i[-],
          :- =>               %i[+],
          :/ =>               %i[*],
          :< =>               %i[== eql? equal?],
          :<< =>              %i[>>],
          :<= =>              %i[< == eql? equal?],
          :== =>              %i[!= eql? equal?],
          :=== =>             %i[is_a?],
          :=~ =>              %i[match?],
          :> =>               %i[== eql? equal?],
          :>= =>              %i[> == eql? equal?],
          :>> =>              %i[<<],
          :^ =>               %i[& |],
          :| =>               %i[& ^],
          __send__:           %i[public_send],
          all?:               %i[any? none?],
          any?:               %i[all? empty? none?],
          append:             %i[prepend],
          assoc:              %i[rassoc],
          at:                 %i[fetch key?],
          bytes:              %i[chars],
          # Bang to non-bang mutations (Array methods)
          capitalize!:        %i[capitalize],
          chars:              %i[bytes],
          chomp!:             %i[chomp],
          chop!:              %i[chop],
          chunk:              %i[each],
          chunk_while:        %i[each],
          collect:            %i[each],
          collect!:           %i[collect],
          collect_concat:     %i[collect],
          compact!:           %i[compact],
          ceil:               %i[floor],
          count:              %i[size length],
          delete!:            %i[delete],
          delete_if:          %i[reject],
          detect:             %i[first last],
          downcase:           %i[upcase],
          downcase!:          %i[downcase],
          drop:               %i[take],
          each_key:           %i[each_value],
          each_cons:          %i[each],
          each_slice:         %i[each],
          each_with_index:    %i[each],
          each_value:         %i[each_key],
          each_with_object:   %i[each],
          empty?:             %i[any?],
          encode!:            %i[encode],
          end_with?:          %i[start_with?],
          even?:              %i[odd?],
          fetch:              %i[key?],
          filter:             %i[reject],
          filter!:            %i[filter],
          filter_map:         %i[map],
          find:               %i[first last],
          first:              %i[last],
          flat_map:           %i[map],
          flatten!:           %i[flatten],
          floor:              %i[ceil],
          grep:               %i[grep_v],
          grep_v:             %i[grep],
          gsub:               %i[sub],
          gsub!:              %i[gsub],
          is_a?:              %i[instance_of?],
          keep_if:            %i[select],
          keys:               %i[values],
          kind_of?:           %i[instance_of?],
          last:               %i[first],
          lstrip!:            %i[lstrip],
          map:                %i[each],
          map!:               %i[map],
          match:              %i[match?],
          max:                %i[first last min],
          max_by:             %i[first last min_by],
          merge!:             %i[merge],
          method:             %i[public_method],
          min:                %i[first last max],
          min_by:             %i[first last max_by],
          negative?:          %i[positive?],
          none?:              %i[any? all?],
          odd?:               %i[even?],
          pop:                %i[shift],
          positive?:          %i[negative?],
          pred:               %i[succ],
          prepend:            %i[append],
          push:               %i[unshift],
          reject:             %i[select],
          reject!:            %i[reject],
          reverse!:           %i[reverse],
          reverse_each:       %i[each],
          reverse_map:        %i[map each],
          reverse_merge:      %i[merge],
          rotate!:            %i[rotate],
          rstrip!:            %i[rstrip],
          sample:             %i[first last],
          scrub!:             %i[scrub],
          rassoc:             %i[assoc],
          select:             %i[reject],
          select!:            %i[select],
          send:               %i[public_send __send__],
          shift:              %i[pop],
          shuffle!:           %i[shuffle],
          slice_after:        %i[each],
          slice_before:       %i[each],
          slice_when:         %i[each],
          sort!:              %i[sort],
          sort_by:            %i[sort],
          sort_by!:           %i[sort_by],
          squeeze!:           %i[squeeze],
          start_with?:        %i[end_with?],
          strip:              %i[lstrip rstrip],
          strip!:             %i[strip],
          sub!:               %i[sub],
          succ:               %i[pred],
          swapcase!:          %i[swapcase],
          take:               %i[drop],
          to_a:               %i[to_ary],
          to_f:               %i[to_i],
          to_h:               %i[to_hash],
          to_i:               %i[to_int],
          to_s:               %i[to_str],
          tr!:                %i[tr],
          tr_s!:              %i[tr_s],
          transform_keys:     %i[transform_values],
          transform_keys!:    %i[transform_keys],
          transform_values:   %i[transform_keys],
          transform_values!:  %i[transform_values],
          unicode_normalize!: %i[unicode_normalize],
          uniq!:              %i[uniq],
          unshift:            %i[push],
          upcase:             %i[downcase],
          upcase!:            %i[upcase],
          values:             %i[keys],
          values_at:          %i[fetch_values],
          zero?:              %i[nonzero?]
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

      def selector_replacements = self.class::SELECTOR_REPLACEMENTS

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
