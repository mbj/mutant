require 'spec_helper'

class CodeLoadingSubject
  def x
    true
  end
end

describe Mutant, 'code loading' do
  let(:context) { Mutant::Context::Constant.build("/some/path",CodeLoadingSubject) }
  let(:node)    { 'def foo; :bar; end'.to_ast                                      }
  let(:root)    { context.root(node)                                               }
                                                                           
  subject       { Mutant::Loader.load(root)                                        }

  before { subject }

  it 'should add the method to subject' do
    CodeLoadingSubject.new.foo.should be(:bar)
  end
end
