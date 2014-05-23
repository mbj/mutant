# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'rescue' do

  context 'multiple exception selectors and assignment' do
    let(:source) { 'begin; rescue ExceptionA, ExceptionB => error; true; end' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'begin; rescue ExceptionA, ExceptionB; true; end'
      mutations << 'begin; rescue ExceptionA, ExceptionB => error; false; end'
      mutations << 'begin; rescue ExceptionA, ExceptionB => error; nil; end'
      mutations << 'begin; rescue ExceptionA => error; true; end'
      mutations << 'begin; rescue ExceptionB => error; true; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'single exception selector and assignment' do
    let(:source) { 'begin; rescue SomeException => error; true; end' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'begin; rescue SomeException; true; end'
      mutations << 'begin; rescue SomeException => error; false; end'
      mutations << 'begin; rescue SomeException => error; nil; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'no exection selector and assignment' do
    let(:source) { 'begin; rescue => error; true end' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'begin; rescue => error; false; end'
      mutations << 'begin; rescue => error; nil; end'
      mutations << 'begin; rescue; true; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'no exection selector and no assignment' do
    let(:source) { 'begin; rescue; true end' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'begin; rescue; false; end'
      mutations << 'begin; rescue; nil; end'
    end

    it_should_behave_like 'a mutator'
  end
end
