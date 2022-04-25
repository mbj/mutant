# frozen_string_literal: true

module Mutant
  class Subject
    class Config
      include Adamantium, Anima.new(:inline_disable)

      DEFAULT = new(inline_disable: false)

      DISABLE_REGEXP = /(\s|^)mutant:disable(?:\s|$)/.freeze
      SYNTAX_REGEXP  = /\A(?:#|=begin\n)/.freeze

      def self.parse(comments)
        new(
          inline_disable: comments.any? { |comment| DISABLE_REGEXP.match?(comment_body(comment)) }
        )
      end

      def self.comment_body(comment)
        comment.text.sub(SYNTAX_REGEXP, '')
      end
      private_class_method :comment_body
    end # Config
  end # Subject
end # Mutant
