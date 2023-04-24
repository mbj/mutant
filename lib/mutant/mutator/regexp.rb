# frozen_string_literal: true

module Mutant
  class Mutator
    class Regexp < self
      def self.regexp_body(node)
        *body, _options = node.children

        body.map do |child|
          return unless child.type.equal?(:str)
          child.children
        end.join
      end

      class Registry
        include Anima.new(:contents)

        def initialize
          super(contents: {})
        end

        def register(expression_class, mutator_class)
          (contents[expression_class] ||= []) << mutator_class
          self
        end

        def lookup(expression_class)
          contents.fetch(expression_class, []).push(Quantifier)
        end
      end # Registry

      REGISTRY = Registry.new

      # mutant:disable - boot time code
      def self.handle(*types)
        types.each do |type|
          self::REGISTRY.register(type, self)
        end
      end

      private_class_method :handle

      def self.mutate(expression)
        REGISTRY
          .lookup(expression.class)
          .map { |mutator| mutator.call(input: expression, parent: nil) }
          .reduce(&:merge)
      end

   private

      def subexpressions
        input.expressions
      end

      def mk_dup
        Marshal.load(Marshal.dump(input))
      end

      def emit_expression(klass:, text:)
        emit(
          klass.construct(text: text).tap do |new|
            subexpressions.each do |expression|
              new << Marshal.load(Marshal.dump(expression))
            end
          end
        )
      end

      def emit_passive_group
        emit_expression(
          klass: ::Regexp::Expression::Group::Passive,
          text:  '(?:'
        )
      end

      class Alternation < self
        handle(::Regexp::Expression::Alternation)

        def dispatch
          subexpressions.each_index do |index|
            emit(mk_dup.tap { |new| new.expressions.delete_at(index) })
          end
        end
      end

      class Quantifier < self
        MAP = {
          '*'  => '+',
          '*+' => '++',
          '*?' => '+?'
        }.freeze

        def dispatch
          return unless input.quantifier

          emit_removal
          emit_replacement
        end

        def emit_removal
          emit(mk_dup.tap { |new| new.quantifier = nil })
        end

        def emit_replacement
          new_text = MAP[input.quantifier.text]

          emit(mk_dup.tap { |new| new.quantifier.text = new_text })
        end
      end

      class Replacement < self
        ns = ::Regexp::Expression

        dual_table =
          [
            [ns::Anchor::WordBoundary,            '\\b', ns::Anchor::NonWordBoundary,  '\\B'],
            [ns::CharacterType::Digit,            '\\d', ns::CharacterType::NonDigit,  '\\D'],
            [ns::CharacterType::ExtendedGrapheme, '\\X', ns::CharacterType::Linebreak, '\\R'],
            [ns::CharacterType::Hex,              '\\h', ns::CharacterType::NonHex,    '\\H'],
            [ns::CharacterType::Space,            '\\s', ns::CharacterType::NonSpace,  '\\S'],
            [ns::CharacterType::Word,             '\\w', ns::CharacterType::NonWord,   '\\W']
          ]

        MAP = dual_table.flat_map do |(left_key, left_text, right_key, right_text)|
          [
            [left_key,  [right_key, right_text]],
            [right_key, [left_key,  left_text]]
          ]
        end.to_h

        MAP[ns::Anchor::BeginningOfLine]              = [ns::Anchor::BeginningOfString, '\\A']
        MAP[ns::Anchor::EndOfLine]                    = [ns::Anchor::EndOfString, '\\z']
        MAP[ns::Anchor::EndOfStringOrBeforeEndOfLine] = [ns::Anchor::EndOfString, '\\z']

        MAP.freeze

        handle(*MAP.keys)

        def dispatch
          klass, text = MAP.fetch(input.class)

          emit(klass.construct(text: text).tap { |new| new.quantifier = input.quantifier })
        end
      end

      class GroupCapturePositional < self
        handle(::Regexp::Expression::Group::Capture)

      private

        def dispatch
          emit_passive_group unless subexpressions.empty?
        end
      end

      class GroupCaptureNamed < self
        handle(::Regexp::Expression::Group::Named)

      private

        def dispatch
          return if input.name.start_with?('_') || subexpressions.empty?

          emit_passive_group

          emit_expression(
            klass: ::Regexp::Expression::Group::Named,
            text:  "(?<_#{input.name}>"
          )
        end
      end

      class Recurse < self
        ns = ::Regexp::Expression

        # This list of nodes with subexessions is not yet complete.
        handle(ns::Assertion::Base)
        handle(ns::Assertion::Lookahead)
        handle(ns::Assertion::Lookbehind)
        handle(ns::Assertion::NegativeLookahead)
        handle(ns::Assertion::NegativeLookbehind)
        handle(ns::Alternative)
        handle(ns::Alternation)
        handle(ns::Sequence)
        handle(ns::CharacterSet)
        handle(ns::CharacterSet::Range)
        handle(ns::Conditional::Branch)
        handle(ns::Conditional::Expression)
        handle(ns::Group::Absence)
        handle(ns::Group::Atomic)
        handle(ns::Group::Capture)
        handle(ns::Group::Comment)
        handle(ns::Group::Named)
        handle(ns::Group::Options)
        handle(ns::Group::Passive)
        handle(ns::Root)

      private

        def dispatch
          subexpressions.each_with_index do |expression, index|
            self.class.mutate(expression).each do |new_expression|
              emit(mk_dup.tap { |new| new.expressions[index] = new_expression })
            end
          end
        end
      end
    end # Regexp
  end # Mutator
end # Mutant
