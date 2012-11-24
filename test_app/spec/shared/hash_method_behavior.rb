# encoding: utf-8

shared_examples_for 'a hash method' do
  it_should_behave_like 'an idempotent method'

  specification = proc do
    should be_instance_of(Fixnum)
  end

  it 'is a fixnum' do
    instance_eval(&specification)
  end

  it 'memoizes the hash code' do
    subject.should eql(object.memoized(:hash))
  end
end
