require 'spec_helper'

describe Mutant::Differ, '#diff' do
  let(:object) { described_class.new(old, new) }

  subject { object.diff }

  context 'when there is a diff at begin of hunk' do
    let(:old) { %w(foo bar) }
    let(:new) { %w(baz bar) }

    it { should eql("@@ -1,3 +1,3 @@\n-foo\n+baz\n bar\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when there is a diff NOT at begin of hunk' do
    let(:old) { %w(foo bar) }
    let(:new) { %w(foo baz bar) }

    it { should eql("@@ -1,3 +1,4 @@\n foo\n+baz\n bar\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when the diff has a long context at begin' do
    let(:old) { %w(foo bar baz boz a b c) }
    let(:new) { %w(foo bar baz boz a b c other) }

    it { should eql("@@ -1,8 +1,9 @@\n foo\n bar\n baz\n boz\n a\n b\n c\n+other\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when the diff has a long context at end, deleting' do
    let(:old) { %w(other foo bar baz boz a b c) }
    let(:new) { %w(foo bar baz boz a b c) }

    it { should eql("@@ -1,9 +1,8 @@\n-other\n foo\n bar\n baz\n boz\n a\n b\n c\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when the diff has a long context at end, inserting' do
    let(:old) { %w(foo bar baz boz a b c) }
    let(:new) { %w(other foo bar baz boz a b c) }

    it { should eql("@@ -1,8 +1,9 @@\n+other\n foo\n bar\n baz\n boz\n a\n b\n c\n") }

    it_should_behave_like 'an idempotent method'
  end

  context 'when there is no diff' do
    let(:old) { '' }
    let(:new) { '' }

    it { should be(nil) }

    it_should_behave_like 'an idempotent method'
  end
end
