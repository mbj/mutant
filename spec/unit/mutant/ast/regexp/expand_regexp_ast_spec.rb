# frozen_string_literal: true

RSpec.describe Mutant::AST::Regexp, '.expand_regexp_ast' do
  it 'returns the expanded AST' do
    parser_ast = Unparser.parse('/foo/')

    expect(described_class.expand_regexp_ast(parser_ast)).to eql(
      s(:regexp_root_expression,
        s(:regexp_literal_literal, 'foo'))
    )
  end

  it 'returns `nil` for complex regexps' do
    parser_ast = Unparser.parse('/foo#{bar}/')

    expect(described_class.expand_regexp_ast(parser_ast)).to be(nil)
  end
end
