require 'spec_helper'

describe Mutant::Differ, '#diff' do
  let(:object) { described_class.new(old, new) }

  subject { object.diff }

  context 'when there is a diff that is at beginning of hunk' do
    let(:old) { "foo\nbar" }
    let(:new) { "baz\nbar" }

    it { should eql("@@ -1,3 +1,3 @@\n-foo\n+baz\n bar\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when there is a diff that is NOT at beginning of hunk' do
    let(:old) { "foo\nbar" }
    let(:new) { "foo\nbaz\nbar" }

    it { should eql("@@ -1,3 +1,4 @@\n foo\n+baz\n bar\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when there is no diff' do
    let(:old) { '' }
    let(:new) { '' }

    it { should be(nil) }

    it_should_behave_like 'an idempotent method'
  end
end
