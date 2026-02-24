# frozen_string_literal: true

module Mutant
  # Represent a mutated node with its subject
  class Mutation
    class Operators
      include Equalizer.new

      class Full < self
        NAME = :full

        SELECTOR_REPLACEMENTS = {
          :!= =>         %i[==],
          :** =>         %i[*],
          :% =>          %i[/],
          :& =>          %i[| ^],
          :* =>          %i[/],
          :+ =>          %i[-],
          :- =>          %i[+],
          :/ =>          %i[*],
          :< =>          %i[== eql? equal?],
          :<< =>         %i[>>],
          :<= =>         %i[< == eql? equal?],
          :== =>         %i[!= eql? equal?],
          :=== =>        %i[is_a?],
          :=~ =>         %i[match?],
          :> =>          %i[== eql? equal?],
          :>= =>         %i[> == eql? equal?],
          :>> =>         %i[<<],
          :^ =>          %i[& |],
          :| =>          %i[& ^],
          __send__:      %i[public_send],
          all?:          %i[any?],
          any?:          %i[all? none?],
          at:            %i[fetch key?],
          # Bang to non-bang mutations (Array methods)
          capitalize!:   %i[capitalize],
          chomp!:        %i[chomp],
          chop!:         %i[chop],
          collect!:      %i[collect],
          compact!:      %i[compact],
          delete!:       %i[delete],
          detect:        %i[first last],
          downcase!:     %i[downcase],
          drop:          %i[take],
          encode!:       %i[encode],
          fetch:         %i[key?],
          filter!:       %i[filter],
          find:          %i[first last],
          first:         %i[last],
          flat_map:      %i[map],
          flatten!:      %i[flatten],
          gsub:          %i[sub],
          gsub!:         %i[gsub],
          is_a?:         %i[instance_of?],
          kind_of?:      %i[instance_of?],
          last:          %i[first],
          lstrip!:       %i[lstrip],
          map:           %i[each],
          map!:          %i[map],
          match:         %i[match?],
          max:           %i[first last],
          max_by:        %i[first last],
          merge!:        %i[merge],
          method:        %i[public_method],
          min:           %i[first last],
          min_by:        %i[first last],
          none?:         %i[any?],
          reject!:       %i[reject],
          reverse!:      %i[reverse],
          reverse_each:  %i[each],
          reverse_map:   %i[map each],
          reverse_merge: %i[merge],
          rotate!:       %i[rotate],
          rstrip!:       %i[rstrip],
          scrub!:        %i[scrub],
          select!:       %i[select],
          send:          %i[public_send __send__],
          shuffle!:      %i[shuffle],
          sort!:         %i[sort],
          sort_by!:      %i[sort_by],
          squeeze!:      %i[squeeze],
          strip!:        %i[strip],
          sub!:          %i[sub],
          swapcase!:     %i[swapcase],
          take:          %i[drop],
          to_a:          %i[to_ary],
          to_h:          %i[to_hash],
          to_i:          %i[to_int],
          to_s:          %i[to_str],
          tr!:           %i[tr],
          tr_s!:         %i[tr_s],
          transform_keys!:   %i[transform_keys],
          transform_values!: %i[transform_values],
          unicode_normalize!: %i[unicode_normalize],
          uniq!:         %i[uniq],
          upcase!:       %i[upcase],
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
