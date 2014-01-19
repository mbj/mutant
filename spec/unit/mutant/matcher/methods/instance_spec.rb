# encoding: utf-8

require 'spec_helper'

describe Mutant::Matcher::Methods::Instance, '#each' do
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
    include Bar

    private :method_d

  public

    def method_a
    end

  protected

    def method_b
    end

  private

    def method_c
    end

  end

  let(:subject_a) { double('Subject A') }
  let(:subject_b) { double('Subject B') }
  let(:subject_c) { double('Subject C') }

  let(:subjects) { [subject_a, subject_b, subject_c] }

  before do
    matcher = Mutant::Matcher::Method::Instance
    matcher.stub(:new)
      .with(cache, Foo, Foo.instance_method(:method_a)).and_return([subject_a])
    matcher.stub(:new)
      .with(cache, Foo, Foo.instance_method(:method_b)).and_return([subject_b])
    matcher.stub(:new)
      .with(cache, Foo, Foo.instance_method(:method_c)).and_return([subject_c])
  end

  it 'should yield expected subjects' do
    subject
    expect(yields).to eql(subjects)
  end

  it_should_behave_like 'an #each method'
end
