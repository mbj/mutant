require 'spec_helper'

describe Mutant,'differ' do
  specify 'allows to create diffs from text' do
    a = "Foo\nBar\n"
    b = "Foo\nBaz\n"
    differ = Mutant::Differ.new(a,b)
    differ.diff.should == strip_indent(<<-RUBY)
      @@ -1,3 +1,3 @@
       Foo
      -Bar
      +Baz
    RUBY
  end
end
