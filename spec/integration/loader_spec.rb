require 'spec_helper'

if "".respond_to?(:to_ast)
  class CodeLoadingSubject
    def x
      true
    end
  end

  describe Mutant, 'code loading' do
    let(:context) { Mutant::Context::Constant.build(CodeLoadingSubject) }
    let(:node)    { 'def foo; :bar; end'.to_ast                         }
    let(:root)    { context.root(node)                                  }
                             
    subject       { Mutant::Loader.load(root)                           }

    before { subject }

    it 'should add the method to subject' do
      CodeLoadingSubject.new.foo.should be(:bar)
    end
  end
end
