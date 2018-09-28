# frozen_string_literal: true

module Mutant
  module AST
    module Regexp
      class Transformer
        # Transformer for nodes which map directly to other domain
        #
        # A node maps "directly" to another domain if the node never
        # has children or text which needs to be preserved for a mapping
        #
        # @example direct mapping
        #
        #     input      = /\d/
        #     expression = Regexp::Parser.parse(input).first
        #     node       = Transformer::Direct.to_ast(expression)
        #
        #     # the digit type always has the same text and no children
        #     expression.text      # => "\\d"
        #     expression.terminal? # => true
        #
        #     # therefore the `Parser::AST::Node` is always the same
        #     node # => s(:regexp_digit_type)
        class Direct < self
          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST
            # Transform expression into node
            #
            # @return [Parser::AST::Node]
            def call
              quantify(ast)
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            include LookupTable

            # rubocop:disable LineLength
            TABLE = Table.create(
              [:regexp_alnum_posixclass,         [:posixclass,    :alnum,            '[:alnum:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_alpha_posixclass,         [:posixclass,    :alpha,            '[:alpha:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_alpha_property,           [:property,      :alpha,            '\p{Alpha}'],    ::Regexp::Expression::UnicodeProperty::Alpha],
              [:regexp_alternation_escape,       [:escape,        :alternation,      '\|'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_arabic_property,          [:property,      :arabic,           '\p{Arabic}'],   ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_ascii_posixclass,         [:posixclass,    :ascii,            '[:ascii:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_backspace_escape,         [:escape,        :backspace,        '\b'],           ::Regexp::Expression::EscapeSequence::Backspace],
              [:regexp_bell_escape,              [:escape,        :bell,             '\a'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_blank_posixclass,         [:posixclass,    :blank,            '[:blank:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_bol_anchor,               [:anchor,        :bol,              '^'],            ::Regexp::Expression::Anchor::BeginningOfLine],
              [:regexp_bol_escape,               [:escape,        :bol,              '\^'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_bos_anchor,               [:anchor,        :bos,              '\\A'],          ::Regexp::Expression::Anchor::BeginningOfString],
              [:regexp_carriage_escape,          [:escape,        :carriage,         '\r'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_cntrl_posixclass,         [:posixclass,    :cntrl,            '[:cntrl:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_digit_posixclass,         [:posixclass,    :digit,            '[:digit:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_digit_type,               [:type,          :digit,            '\d'],           ::Regexp::Expression::CharacterType::Digit],
              [:regexp_dot_escape,               [:escape,        :dot,              '\.'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_dot_meta,                 [:meta,          :dot,              '.'],            ::Regexp::Expression::CharacterType::Any],
              [:regexp_eol_anchor,               [:anchor,        :eol,              '$'],            ::Regexp::Expression::Anchor::EndOfLine],
              [:regexp_eol_escape,               [:escape,        :eol,              '\$'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_eos_anchor,               [:anchor,        :eos,              '\\z'],          ::Regexp::Expression::Anchor::EndOfString],
              [:regexp_eos_ob_eol_anchor,        [:anchor,        :eos_ob_eol,       '\\Z'],          ::Regexp::Expression::Anchor::EndOfStringOrBeforeEndOfLine],
              [:regexp_escape_escape,            [:escape,        :escape,           '\e'],           ::Regexp::Expression::EscapeSequence::AsciiEscape],
              [:regexp_form_feed_escape,         [:escape,        :form_feed,        '\f'],           ::Regexp::Expression::EscapeSequence::FormFeed],
              [:regexp_graph_posixclass,         [:posixclass,    :graph,            '[:graph:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_group_close_escape,       [:escape,        :group_close,      '\)'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_group_open_escape,        [:escape,        :group_open,       '\('],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_han_property,             [:property,      :han,              '\p{Han}'],      ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_hangul_property,          [:property,      :hangul,           '\p{Hangul}'],   ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_hex_type,                 [:type,          :hex,              '\h'],           ::Regexp::Expression::CharacterType::Hex],
              [:regexp_hiragana_property,        [:property,      :hiragana,         '\p{Hiragana}'], ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_interval_close_escape,    [:escape,        :interval_close,   '\}'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_interval_open_escape,     [:escape,        :interval_open,    '\{'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_katakana_property,        [:property,      :katakana,         '\p{Katakana}'], ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_letter_property,          [:property,      :letter,           '\p{L}'],        ::Regexp::Expression::UnicodeProperty::Letter::Any],
              [:regexp_linebreak_type,           [:type,          :linebreak,        '\R'],           ::Regexp::Expression::CharacterType::Linebreak],
              [:regexp_lower_posixclass,         [:posixclass,    :lower,            '[:lower:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_mark_keep,                [:keep,          :mark,             '\K'],           ::Regexp::Expression::Keep::Mark],
              [:regexp_match_start_anchor,       [:anchor,        :match_start,      '\\G'],          ::Regexp::Expression::Anchor::MatchStart],
              [:regexp_newline_escape,           [:escape,        :newline,          '\n'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_nondigit_type,            [:type,          :nondigit,         '\D'],           ::Regexp::Expression::CharacterType::NonDigit],
              [:regexp_nonhex_type,              [:type,          :nonhex,           '\H'],           ::Regexp::Expression::CharacterType::NonHex],
              [:regexp_nonspace_type,            [:type,          :nonspace,         '\S'],           ::Regexp::Expression::CharacterType::NonSpace],
              [:regexp_nonword_boundary_anchor,  [:anchor,        :nonword_boundary, '\\B'],          ::Regexp::Expression::Anchor::NonWordBoundary],
              [:regexp_nonword_type,             [:type,          :nonword,          '\W'],           ::Regexp::Expression::CharacterType::NonWord],
              [:regexp_one_or_more_escape,       [:escape,        :one_or_more,      '\+'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_print_nonposixclass,      [:nonposixclass, :print,            '[:^print:]'],   ::Regexp::Expression::PosixClass],
              [:regexp_print_nonproperty,        [:nonproperty,   :print,            '\P{Print}'],    ::Regexp::Expression::UnicodeProperty::Print],
              [:regexp_print_posixclass,         [:posixclass,    :print,            '[:print:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_print_posixclass,         [:posixclass,    :print,            '[:print:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_print_property,           [:property,      :print,            '\p{Print}'],    ::Regexp::Expression::UnicodeProperty::Print],
              [:regexp_punct_posixclass,         [:posixclass,    :punct,            '[:punct:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_set_close_escape,         [:escape,        :set_close,        '\]'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_set_open_escape,          [:escape,        :set_open,         '\['],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_space_posixclass,         [:posixclass,    :space,            '[:space:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_space_type,               [:type,          :space,            '\s'],           ::Regexp::Expression::CharacterType::Space],
              [:regexp_upper_posixclass,         [:posixclass,    :upper,            '[:upper:]'],    ::Regexp::Expression::PosixClass],
              [:regexp_vertical_tab_escape,      [:escape,        :vertical_tab,     '\v'],           ::Regexp::Expression::EscapeSequence::VerticalTab],
              [:regexp_word_boundary_anchor,     [:anchor,        :word_boundary,    '\b'],           ::Regexp::Expression::Anchor::WordBoundary],
              [:regexp_word_posixclass,          [:posixclass,    :word,             '[:word:]'],     ::Regexp::Expression::PosixClass],
              [:regexp_word_type,                [:type,          :word,             '\w'],           ::Regexp::Expression::CharacterType::Word],
              [:regexp_xdigit_posixclass,        [:posixclass,    :xdigit,           '[:xdigit:]'],   ::Regexp::Expression::PosixClass],
              [:regexp_xgrapheme_type,           [:type,          :xgrapheme,        '\X'],           ::Regexp::Expression::CharacterType::ExtendedGrapheme],
              [:regexp_zero_or_more_escape,      [:escape,        :zero_or_more,     '\*'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_zero_or_one_escape,       [:escape,        :zero_or_one,      '\?'],           ::Regexp::Expression::EscapeSequence::Literal]
            )

          private

            # Transform ast into expression
            #
            # @return [Regexp::Expression]
            def transform
              expression_class.new(expression_token)
            end
          end # ASTToExpression

          ASTToExpression::TABLE.types.each(&method(:register))
        end # Direct
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
