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
              [:regexp_one_or_more_escape,       [:escape,   :one_or_more,      '\+'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_zero_or_one_escape,       [:escape,   :zero_or_one,      '\?'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_alternation_escape,       [:escape,   :alternation,      '\|'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_group_open_escape,        [:escape,   :group_open,       '\('],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_group_close_escape,       [:escape,   :group_close,      '\)'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_interval_open_escape,     [:escape,   :interval_open,    '\{'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_interval_close_escape,    [:escape,   :interval_close,   '\}'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_newline_escape,           [:escape,   :newline,          '\n'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_zero_or_more_escape,      [:escape,   :zero_or_more,     '\*'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_carriage_escape,          [:escape,   :carriage,         '\r'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_dot_escape,               [:escape,   :dot,              '\.'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_set_open_escape,          [:escape,   :set_open,         '\['],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_set_close_escape,         [:escape,   :set_close,        '\]'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_eol_escape,               [:escape,   :eol,              '\$'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_bol_escape,               [:escape,   :bol,              '\^'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_bell_escape,              [:escape,   :bell,             '\a'],           ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_escape_escape,            [:escape,   :escape,           '\e'],           ::Regexp::Expression::EscapeSequence::AsciiEscape],
              [:regexp_form_feed_escape,         [:escape,   :form_feed,        '\f'],           ::Regexp::Expression::EscapeSequence::FormFeed],
              [:regexp_vertical_tab_escape,      [:escape,   :vertical_tab,     '\v'],           ::Regexp::Expression::EscapeSequence::VerticalTab],
              [:regexp_mark_keep,                [:keep,     :mark,             '\K'],           ::Regexp::Expression::Keep::Mark],
              [:regexp_bos_anchor,               [:anchor,   :bos,              '\\A'],          ::Regexp::Expression::Anchor::BeginningOfString],
              [:regexp_match_start_anchor,       [:anchor,   :match_start,      '\\G'],          ::Regexp::Expression::Anchor::MatchStart],
              [:regexp_word_boundary_anchor,     [:anchor,   :word_boundary,    '\b'],           ::Regexp::Expression::Anchor::WordBoundary],
              [:regexp_eos_ob_eol_anchor,        [:anchor,   :eos_ob_eol,       '\\Z'],          ::Regexp::Expression::Anchor::EndOfStringOrBeforeEndOfLine],
              [:regexp_eos_anchor,               [:anchor,   :eos,              '\\z'],          ::Regexp::Expression::Anchor::EndOfString],
              [:regexp_bol_anchor,               [:anchor,   :bol,              '^'],            ::Regexp::Expression::Anchor::BeginningOfLine],
              [:regexp_eol_anchor,               [:anchor,   :eol,              '$'],            ::Regexp::Expression::Anchor::EndOfLine],
              [:regexp_nonword_boundary_anchor,  [:anchor,   :nonword_boundary, '\\B'],          ::Regexp::Expression::Anchor::NonWordBoundary],
              [:regexp_alpha_property,           [:property, :alpha,            '\p{Alpha}'],    ::Regexp::Expression::UnicodeProperty::Alpha],
              [:regexp_script_arabic_property,   [:property, :script_arabic,    '\p{Arabic}'],   ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_script_hangul_property,   [:property, :script_hangul,    '\p{Hangul}'],   ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_script_han_property,      [:property, :script_han,       '\p{Han}'],      ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_script_hiragana_property, [:property, :script_hiragana,  '\p{Hiragana}'], ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_script_katakana_property, [:property, :script_katakana,  '\p{Katakana}'], ::Regexp::Expression::UnicodeProperty::Script],
              [:regexp_letter_any_property,      [:property, :letter_any,       '\p{L}'],        ::Regexp::Expression::UnicodeProperty::Letter::Any],
              [:regexp_hex_type,                 [:type,     :hex,              '\h'],           ::Regexp::Expression::CharacterType::Hex],
              [:regexp_digit_type,               [:type,     :digit,            '\d'],           ::Regexp::Expression::CharacterType::Digit],
              [:regexp_space_type,               [:type,     :space,            '\s'],           ::Regexp::Expression::CharacterType::Space],
              [:regexp_word_type,                [:type,     :word,             '\w'],           ::Regexp::Expression::CharacterType::Word],
              [:regexp_hex_type,                 [:type,     :hex,              '\h'],           ::Regexp::Expression::CharacterType::Hex],
              [:regexp_nonhex_type,              [:type,     :nonhex,           '\H'],           ::Regexp::Expression::CharacterType::NonHex],
              [:regexp_nondigit_type,            [:type,     :nondigit,         '\D'],           ::Regexp::Expression::CharacterType::NonDigit],
              [:regexp_nonspace_type,            [:type,     :nonspace,         '\S'],           ::Regexp::Expression::CharacterType::NonSpace],
              [:regexp_nonword_type,             [:type,     :nonword,          '\W'],           ::Regexp::Expression::CharacterType::NonWord],
              [:regexp_dot_meta,                 [:meta,     :dot,              '.'],            ::Regexp::Expression::CharacterType::Any]
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
