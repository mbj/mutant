# encoding: utf-8

require 'spec_helper'

describe Mutant::Matcher::Methods::Singleton, '#each' do
  let(:object) { described_class.new(cache, Foo) }
  let(:cache)  { Mutant::Cache.new               }

  subject { object.each { |matcher| yields << matcher } }

  let(:yields) { [] }

  module Bar
    def method_d
    end

    def method_e
    end
  end

  class Foo
    extend Bar

    def self.method_a
    end

    def self.method_b
    end
    class << self; protected :method_b; end

    def self.method_c
    end
    private_class_method :method_c

  end

  let(:subject_a) { double('Subject A') }
  let(:subject_b) { double('Subject B') }
  let(:subject_c) { double('Subject C') }

  let(:subjects) { [subject_a, subject_b, subject_c] }

  before do
    matcher = Mutant::Matcher::Method::Singleton
    matcher.stub(:new)
      .with(cache, Foo, Foo.method(:method_a)).and_return([subject_a])
    matcher.stub(:new)
      .with(cache, Foo, Foo.method(:method_b)).and_return([subject_b])
    matcher.stub(:new)
      .with(cache, Foo, Foo.method(:method_c)).and_return([subject_c])
  end

  it 'should yield expected subjects' do
    subject
    yields.should eql(subjects)
  end

  it_should_behave_like 'an #each method'
end
