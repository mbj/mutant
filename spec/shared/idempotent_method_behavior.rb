# encoding: utf-8

shared_examples_for 'an idempotent method' do
  it 'is idempotent' do
    first = subject
    __memoized.delete(:subject)
    should equal(first)
  end
end
