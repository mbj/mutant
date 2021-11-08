# frozen_string_literal: true

module Mutant
  class Expression
    class Rails < self
      include Anima.new(:matcher, :syntax)

      application_controller = Matcher::Descendant.new(const_name: 'ApplicationController')
      application_record     = Matcher::Descendant.new(const_name: 'ApplicationRecord')

      MAP = {
        'rails:controllers' => application_controller,
        'rails:models'      => application_record,
        'rails:*'           => Matcher::Chain.new([application_controller, application_record])
      }.freeze

      def self.try_parse(syntax)
        matcher = MAP[syntax] or return

        new(matcher: matcher, syntax: syntax)
      end
    end # Rails
  end # Expression
end # Mutant
