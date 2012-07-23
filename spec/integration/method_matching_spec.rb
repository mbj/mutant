require 'spec_helper'
if defined?(Rubinius)
  class Toplevel
    def simple
    end

    def self.simple
    end

    def multiple; end; 
    def multiple(foo); end
    
    def self.complex; end; def complex(foo); end

    class Nested
      def foo
      end
    end

    attr_reader :foo

    def multiline(
      foo
    )
    end
  end

  describe Mutant,'method matching' do
    def match(input)
      Mutant::Matcher::Method.parse(input).to_a.first
    end

    it 'allows to match simple instance methods' do
      match = match('Toplevel#simple')
      match.name.should be(:simple)
      match.line.should be(4)
      match.arguments.required.should be_empty
    end

    it 'allows to match simple singleton methods' do
      match = match('Toplevel.simple')
      match.name.should be(:simple)
      match.line.should be(7)
      match.arguments.required.should be_empty
    end

    it 'returns last method definition' do
      match = match('Toplevel#multiple')
      match.name.should be(:multiple)
      match.line.should be(11)
      match.arguments.required.length.should be(1)
    end

    it 'does not fail on multiple definitions of differend scope per row' do
      match = match('Toplevel.complex')
      match.name.should be(:complex)
      match.line.should be(13)
      match.arguments.required.length.should be(0)
    end

    it 'allows matching on nested methods' do
      match = match('Toplevel::Nested#foo')
      match.name.should be(:foo)
      match.line.should be(16)
      match.arguments.required.length.should be(0)
    end

  # pending 'allows matching on attr_readers' do
  #   match = match('Toplevel#foo')
  #   match.name.should be(:foo)
  #   match.line.should be(19)
  #   match.arguments.required.length.should be(0)
  # end

    it 'does not fail on multi line defs' do
      match = match('Toplevel#multiline')
      match.name.should be(:multiline)
      match.line.should be(23)
      match.arguments.required.length.should be(1)
    end
  end
end
