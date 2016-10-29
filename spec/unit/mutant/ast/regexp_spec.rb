module RegexpSpec
  class Expression < SimpleDelegator
    NO_EXPRESSIONS = Object.new.freeze

    include Equalizer.new(:type, :token, :text, :quantifier, :expressions)

    def quantifier
      return Quantifier::NONE unless quantified?

      Quantifier.new(super())
    end

    def expressions
      return NO_EXPRESSIONS if terminal?

      super().map(&self.class.public_method(:new))
    end

    class Quantifier < SimpleDelegator
      NONE = Object.new.freeze

      include Equalizer.new(:token, :text, :mode, :min, :max)
    end # Quantifier
  end # Expression

  RSpec.shared_context 'regexp transformation' do
    let(:parsed)     { Mutant::AST::Regexp.parse(regexp)      }
    let(:ast)        { Mutant::AST::Regexp.to_ast(parsed)     }
    let(:expression) { Mutant::AST::Regexp.to_expression(ast) }

    def expect_frozen_expression(expression, root = expression)
      expect(expression.frozen?).to(
        be(true),
        "Expected #{root} to be deep frozen"
      )

      return if expression.terminal?

      expression.expressions.each do |subexpression|
        expect_frozen_expression(subexpression, root)
      end
    end

    it 'transforms into ast' do
      expect(ast).to eql(expected)
    end

    it 'deep freezes expression mapping' do
      expect_frozen_expression(expression)
    end

    it 'transforms ast back to expression' do
      expect(Expression.new(expression)).to eql(Expression.new(parsed))
    end
  end

  RSpec.shared_context 'regexp round trip' do
    let(:round_trip) { expression.to_re }

    it 'round trips Regexp' do
      expect(round_trip).to eql(regexp)
    end
  end

  def self.expect_mapping(regexp, type, &block)
    RSpec.describe Mutant::AST::Regexp::Transformer.lookup(type) do
      context "when mapping #{regexp.inspect}" do
        let(:regexp) { regexp }
        let(:expected, &block)

        include_context 'regexp transformation'

        unless regexp.encoding.name.eql?('ASCII-8BIT')
          include_context 'regexp round trip'
        end
      end
    end
  end
end # RegexpSpec

RegexpSpec.expect_mapping(/A/, :regexp_root_expression) do
  s(:regexp_root_expression,
    s(:regexp_literal_literal, 'A'))
end

RegexpSpec.expect_mapping(/\p{Alpha}/, :regexp_alpha_property) do
  s(:regexp_root_expression,
    s(:regexp_alpha_property))
end

RegexpSpec.expect_mapping(/foo|bar/, :regexp_alternation_meta) do
  s(:regexp_root_expression,
    s(:regexp_alternation_meta,
      s(:regexp_sequence_expression,
        s(:regexp_literal_literal, 'foo')),
      s(:regexp_sequence_expression,
        s(:regexp_literal_literal, 'bar'))))
end

RegexpSpec.expect_mapping(/(?>a)/, :regexp_atomic_group) do
  s(:regexp_root_expression,
    s(:regexp_atomic_group,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/\\/, :regexp_backslash_escape) do
  s(:regexp_root_expression,
    s(:regexp_backslash_escape, '\\\\'))
end

RegexpSpec.expect_mapping(/^/, :regexp_bol_anchor) do
  s(:regexp_root_expression,
    s(:regexp_bol_anchor))
end

RegexpSpec.expect_mapping(/\^/, :regexp_bol_escape) do
  s(:regexp_root_expression,
    s(:regexp_bol_escape))
end

RegexpSpec.expect_mapping(/\A/, :regexp_bos_anchor) do
  s(:regexp_root_expression,
    s(:regexp_bos_anchor))
end

RegexpSpec.expect_mapping(/(foo)/, :regexp_capture_group) do
  s(:regexp_root_expression,
    s(:regexp_capture_group,
      s(:regexp_literal_literal, 'foo')))
end

RegexpSpec.expect_mapping(/()\1/, :regexp_number_backref) do
  s(:regexp_root_expression,
    s(:regexp_capture_group),
    s(:regexp_number_backref, '\\1'))
end

RegexpSpec.expect_mapping(/(a)*/, :regexp_capture_group) do
  s(:regexp_root_expression,
    s(:regexp_greedy_zero_or_more, 0, -1,
      s(:regexp_capture_group,
        s(:regexp_literal_literal, 'a'))))
end

RegexpSpec.expect_mapping(/\r/, :regexp_carriage_escape) do
  s(:regexp_root_expression,
    s(:regexp_carriage_escape))
end

RegexpSpec.expect_mapping(/\a/, :regexp_bell_escape) do
  s(:regexp_root_expression,
    s(:regexp_bell_escape))
end

RegexpSpec.expect_mapping(/\?/, :regexp_zero_or_one_escape) do
  s(:regexp_root_expression,
    s(:regexp_zero_or_one_escape))
end

RegexpSpec.expect_mapping(/\|/, :regexp_alternation_escape) do
  s(:regexp_root_expression,
    s(:regexp_alternation_escape))
end

RegexpSpec.expect_mapping(/\c2/, :regexp_control_escape) do
  s(:regexp_root_expression,
    s(:regexp_control_escape, '\\c2'))
end

RegexpSpec.expect_mapping(/\M-B/n, :regexp_meta_sequence_escape) do
  s(:regexp_root_expression,
    s(:regexp_meta_sequence_escape, '\M-B'))
end

RegexpSpec.expect_mapping(/\K/, :regexp_mark_keep) do
  s(:regexp_root_expression,
    s(:regexp_mark_keep))
end

RegexpSpec.expect_mapping(/\e/, :regexp_escape_escape) do
  s(:regexp_root_expression,
    s(:regexp_escape_escape))
end

RegexpSpec.expect_mapping(/\f/, :regexp_form_feed_escape) do
  s(:regexp_root_expression,
    s(:regexp_form_feed_escape))
end

RegexpSpec.expect_mapping(/\v/, :regexp_vertical_tab_escape) do
  s(:regexp_root_expression,
    s(:regexp_vertical_tab_escape))
end

RegexpSpec.expect_mapping(/\e/, :regexp_escape_escape) do
  s(:regexp_root_expression,
    s(:regexp_escape_escape))
end

RegexpSpec.expect_mapping(/[ab]+/, :regexp_character_set) do
  s(:regexp_root_expression,
    s(:regexp_greedy_one_or_more, 1, -1,
      s(:regexp_character_set, 'a', 'b')))
end

RegexpSpec.expect_mapping(/[ab]/, :regexp_character_set) do
  s(:regexp_root_expression,
    s(:regexp_character_set, 'a', 'b'))
end

RegexpSpec.expect_mapping(/[a-j]/, :regexp_character_set) do
  s(:regexp_root_expression,
    s(:regexp_character_set, 'a-j'))
end

RegexpSpec.expect_mapping(/\u{9879}/, :regexp_codepoint_list_escape) do
  s(:regexp_root_expression,
    s(:regexp_codepoint_list_escape, '\\u{9879}'))
end

RegexpSpec.expect_mapping(/(?#foo)/, :regexp_comment_group) do
  s(:regexp_root_expression,
    s(:regexp_comment_group, '(?#foo)'))
end

RegexpSpec.expect_mapping(/(?x-: # comment
)/, :regexp_comment_free_space) do
  s(:regexp_root_expression,
    s(:regexp_options_group, {
        m: false,
        i: false,
        x: true,
        d: false,
        a: false,
        u: false
      },
      s(:regexp_whitespace_free_space, ' '),
      s(:regexp_comment_free_space, "# comment\n")))
end

RegexpSpec.expect_mapping(/\d/, :regexp_digit_type) do
  s(:regexp_root_expression,
    s(:regexp_digit_type))
end

RegexpSpec.expect_mapping(/\./, :regexp_dot_escape) do
  s(:regexp_root_expression,
    s(:regexp_dot_escape))
end

RegexpSpec.expect_mapping(/.+/, :regexp_dot_meta) do
  s(:regexp_root_expression,
    s(:regexp_greedy_one_or_more, 1, -1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/$/, :regexp_eol_anchor) do
  s(:regexp_root_expression,
    s(:regexp_eol_anchor))
end

RegexpSpec.expect_mapping(/\$/, :regexp_eol_escape) do
  s(:regexp_root_expression,
    s(:regexp_eol_escape))
end

RegexpSpec.expect_mapping(/\z/, :regexp_eos_anchor) do
  s(:regexp_root_expression,
    s(:regexp_eos_anchor))
end

RegexpSpec.expect_mapping(/\Z/, :regexp_eos_ob_eol_anchor) do
  s(:regexp_root_expression,
    s(:regexp_eos_ob_eol_anchor))
end

RegexpSpec.expect_mapping(/a{1,}/, :regexp_greedy_interval) do
  s(:regexp_root_expression,
    s(:regexp_greedy_interval, 1, -1,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/.{2}/, :regexp_greedy_interval) do
  s(:regexp_root_expression,
    s(:regexp_greedy_interval, 2, 2,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.{3,5}/, :regexp_greedy_interval) do
  s(:regexp_root_expression,
    s(:regexp_greedy_interval, 3, 5,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.{,3}/, :regexp_greedy_interval) do
  s(:regexp_root_expression,
    s(:regexp_greedy_interval, 0, 3,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.+/, :regexp_greedy_one_or_more) do
  s(:regexp_root_expression,
    s(:regexp_greedy_one_or_more, 1, -1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/[ab]+/, :regexp_greedy_one_or_more) do
  s(:regexp_root_expression,
    s(:regexp_greedy_one_or_more, 1, -1,
      s(:regexp_character_set, 'a', 'b')))
end

RegexpSpec.expect_mapping(/(a)*/, :regexp_greedy_zero_or_more) do
  s(:regexp_root_expression,
    s(:regexp_greedy_zero_or_more, 0, -1,
      s(:regexp_capture_group,
        s(:regexp_literal_literal, 'a'))))
end

RegexpSpec.expect_mapping(/.*/, :regexp_greedy_zero_or_more) do
  s(:regexp_root_expression,
    s(:regexp_greedy_zero_or_more, 0, -1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.?/, :regexp_greedy_zero_or_one) do
  s(:regexp_root_expression,
    s(:regexp_greedy_zero_or_one, 0, 1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/\)/, :regexp_group_close_escape) do
  s(:regexp_root_expression,
    s(:regexp_group_close_escape))
end

RegexpSpec.expect_mapping(/\(/, :regexp_group_open_escape) do
  s(:regexp_root_expression,
    s(:regexp_group_open_escape))
end

RegexpSpec.expect_mapping(/\xFF/n, :regexp_hex_escape) do
  s(:regexp_root_expression,
    s(:regexp_hex_escape, '\\xFF'))
end

RegexpSpec.expect_mapping(/\h/, :regexp_hex_type) do
  s(:regexp_root_expression,
    s(:regexp_hex_type))
end

RegexpSpec.expect_mapping(/\H/, :regexp_hex_type) do
  s(:regexp_root_expression,
    s(:regexp_nonhex_type))
end

RegexpSpec.expect_mapping(/\}/, :regexp_interval_close_escape) do
  s(:regexp_root_expression,
    s(:regexp_interval_close_escape))
end

RegexpSpec.expect_mapping(/\{/, :regexp_interval_open_escape) do
  s(:regexp_root_expression,
    s(:regexp_interval_open_escape))
end

RegexpSpec.expect_mapping(/\p{L}/, :regexp_letter_any_property) do
  s(:regexp_root_expression,
    s(:regexp_letter_any_property))
end

RegexpSpec.expect_mapping(/\-/, :regexp_literal_escape) do
  s(:regexp_root_expression,
    s(:regexp_literal_escape, '\\-'))
end

RegexpSpec.expect_mapping(/\ /, :regexp_literal_escape) do
  s(:regexp_root_expression,
    s(:regexp_literal_escape, '\\ '))
end

RegexpSpec.expect_mapping(/\#/, :regexp_literal_escape) do
  s(:regexp_root_expression,
    s(:regexp_literal_escape, '\\#'))
end

RegexpSpec.expect_mapping(/\:/, :regexp_literal_escape) do
  s(:regexp_root_expression,
    s(:regexp_literal_escape, '\\:'))
end

RegexpSpec.expect_mapping(/\</, :regexp_literal_escape) do
  s(:regexp_root_expression,
    s(:regexp_literal_escape, '\\<'))
end

RegexpSpec.expect_mapping(/foo/, :regexp_literal_literal) do
  s(:regexp_root_expression,
    s(:regexp_literal_literal, 'foo'))
end

RegexpSpec.expect_mapping(/a+/, :regexp_literal_literal) do
  s(:regexp_root_expression,
    s(:regexp_greedy_one_or_more, 1, -1,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/(?=a)/, :regexp_lookahead_assertion) do
  s(:regexp_root_expression,
    s(:regexp_lookahead_assertion,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/(?<=a)/, :regexp_lookbehind_assertion) do
  s(:regexp_root_expression,
    s(:regexp_lookbehind_assertion,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/\G/, :regexp_match_start_anchor) do
  s(:regexp_root_expression,
    s(:regexp_match_start_anchor))
end

RegexpSpec.expect_mapping(/(?<foo>)/, :regexp_named_group) do
  s(:regexp_root_expression,
    s(:regexp_named_group, '(?<foo>'))
end

RegexpSpec.expect_mapping(/(?<a>)\g<a>/, :regexp_name_call_backref) do
  s(:regexp_root_expression,
    s(:regexp_named_group, '(?<a>'),
    s(:regexp_name_call_backref, '\\g<a>'))
end

RegexpSpec.expect_mapping(/\n/, :regexp_newline_escape) do
  s(:regexp_root_expression,
    s(:regexp_newline_escape))
end

RegexpSpec.expect_mapping(/(?!a)/, :regexp_nlookahead_assertion) do
  s(:regexp_root_expression,
    s(:regexp_nlookahead_assertion,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/(?<!a)/, :regexp_nlookbehind_assertion) do
  s(:regexp_root_expression,
    s(:regexp_nlookbehind_assertion,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/\D/, :regexp_nondigit_type) do
  s(:regexp_root_expression,
    s(:regexp_nondigit_type))
end

RegexpSpec.expect_mapping(/\S/, :regexp_nonspace_type) do
  s(:regexp_root_expression,
    s(:regexp_nonspace_type))
end

RegexpSpec.expect_mapping(/\B/, :regexp_nonword_boundary_anchor) do
  s(:regexp_root_expression,
    s(:regexp_nonword_boundary_anchor))
end

RegexpSpec.expect_mapping(/\W/, :regexp_nonword_type) do
  s(:regexp_root_expression,
    s(:regexp_nonword_type))
end

RegexpSpec.expect_mapping(/\+/, :regexp_one_or_more_escape) do
  s(:regexp_root_expression,
    s(:regexp_one_or_more_escape))
end

RegexpSpec.expect_mapping(/(?i-:a)+/, :regexp_options_group) do
  s(:regexp_root_expression,
    s(:regexp_greedy_one_or_more, 1, -1,
      s(:regexp_options_group,
        {
          m: false,
          i: true,
          x: false,
          d: false,
          a: false,
          u: false
        },
        s(:regexp_literal_literal, 'a'))))
end

RegexpSpec.expect_mapping(/(?x-: #{"\n"} )/, :regexp_whitespace_free_space) do
  s(:regexp_root_expression,
    s(:regexp_options_group,
      {
        m: false,
        i: false,
        x: true,
        d: false,
        a: false,
        u: false
      },
      s(:regexp_whitespace_free_space, " \n ")))
end

RegexpSpec.expect_mapping(/(?:a)/, :regexp_passive_group) do
  s(:regexp_root_expression,
    s(:regexp_passive_group,
      s(:regexp_literal_literal, 'a')))
end

RegexpSpec.expect_mapping(/.{1,3}+/, :regexp_possessive_interval) do
  s(:regexp_root_expression,
    s(:regexp_possessive_interval, 1, 3,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.++/, :regexp_possessive_one_or_more) do
  s(:regexp_root_expression,
    s(:regexp_possessive_one_or_more, 1, -1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.*+/, :regexp_possessive_zero_or_more) do
  s(:regexp_root_expression,
    s(:regexp_possessive_zero_or_more, 0, -1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.?+/, :regexp_possessive_zero_or_one) do
  s(:regexp_root_expression,
    s(:regexp_possessive_zero_or_one, 0, 1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.{1,3}?/, :regexp_reluctant_interval) do
  s(:regexp_root_expression,
    s(:regexp_reluctant_interval, 1, 3,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.+?/, :regexp_reluctant_one_or_more) do
  s(:regexp_root_expression,
    s(:regexp_reluctant_one_or_more, 1, -1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/.*?/, :regexp_reluctant_zero_or_more) do
  s(:regexp_root_expression,
    s(:regexp_reluctant_zero_or_more, 0, -1,
      s(:regexp_dot_meta)))
end

RegexpSpec.expect_mapping(/\p{Arabic}/, :regexp_script_arabic_property) do
  s(:regexp_root_expression,
    s(:regexp_script_arabic_property))
end

RegexpSpec.expect_mapping(/\p{Han}/, :regexp_script_han_property) do
  s(:regexp_root_expression,
    s(:regexp_script_han_property))
end

RegexpSpec.expect_mapping(/\p{Hangul}/, :regexp_script_hangul_property) do
  s(:regexp_root_expression,
    s(:regexp_script_hangul_property))
end

RegexpSpec.expect_mapping(/\p{Hiragana}/, :regexp_script_hiragana_property) do
  s(:regexp_root_expression,
    s(:regexp_script_hiragana_property))
end

RegexpSpec.expect_mapping(/\p{Katakana}/, :regexp_script_katakana_property) do
  s(:regexp_root_expression,
    s(:regexp_script_katakana_property))
end

RegexpSpec.expect_mapping(/foo|bar/, :regexp_sequence_expression) do
  s(:regexp_root_expression,
    s(:regexp_alternation_meta,
      s(:regexp_sequence_expression,
        s(:regexp_literal_literal, 'foo')),
      s(:regexp_sequence_expression,
        s(:regexp_literal_literal, 'bar'))))
end

RegexpSpec.expect_mapping(/\]/, :regexp_set_close_escape) do
  s(:regexp_root_expression,
    s(:regexp_set_close_escape))
end

RegexpSpec.expect_mapping(/\[/, :regexp_set_open_escape) do
  s(:regexp_root_expression,
    s(:regexp_set_open_escape))
end

RegexpSpec.expect_mapping(/\s/, :regexp_space_type) do
  s(:regexp_root_expression,
    s(:regexp_space_type))
end

RegexpSpec.expect_mapping(/\t/, :regexp_tab_escape) do
  s(:regexp_root_expression,
    s(:regexp_tab_escape, '\\t'))
end

RegexpSpec.expect_mapping(/\b/, :regexp_word_boundary_anchor) do
  s(:regexp_root_expression,
    s(:regexp_word_boundary_anchor))
end

RegexpSpec.expect_mapping(/\w/, :regexp_word_type) do
  s(:regexp_root_expression,
    s(:regexp_word_type))
end

RegexpSpec.expect_mapping(/\h/, :regexp_hex_type) do
  s(:regexp_root_expression,
    s(:regexp_hex_type))
end

RegexpSpec.expect_mapping(/\*/, :regexp_zero_or_more_escape) do
  s(:regexp_root_expression,
    s(:regexp_zero_or_more_escape))
end
