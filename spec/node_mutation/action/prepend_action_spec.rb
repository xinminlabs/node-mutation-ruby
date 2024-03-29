# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NodeMutation::PrependAction do
  let(:adapter) { NodeMutation::ParserAdapter.new }

  describe 'block node without args' do
    subject {
      source = "Synvert::Application.configure do\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(node, 'config.eager_load = true', adapter: adapter).process
    }

    it 'gets start' do
      expect(subject.start).to eq "Synvert::Application.configure do\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "Synvert::Application.configure do\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  config.eager_load = true\n"
    end
  end

  describe 'block node with args' do
    subject {
      source = "RSpec.configure do |config|\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(
        node,
        '{{arguments.first}}.include FactoryGirl::Syntax::Methods',
        adapter: adapter
      ).process
    }

    it 'gets start' do
      expect(subject.start).to eq "RSpec.configure do |config|\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "RSpec.configure do |config|\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  config.include FactoryGirl::Syntax::Methods\n"
    end
  end

  describe 'class node without superclass' do
    subject {
      source = "class User\n  has_many :posts\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(node, 'include Deletable', adapter: adapter).process
    }

    it 'gets start' do
      expect(subject.start).to eq "class User\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "class User\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  include Deletable\n"
    end
  end

  describe 'class node with superclass' do
    subject {
      source = "class User < ActiveRecord::Base\n  has_many :posts\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(node, 'include Deletable', adapter: adapter).process
    }

    it 'gets start' do
      expect(subject.start).to eq "class User < ActionRecord::Base\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "class User < ActionRecord::Base\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  include Deletable\n"
    end
  end

  describe 'def node without args' do
    subject do
      source = "def setup\n  do_something\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(node, 'super', adapter: adapter).process
    end

    it 'gets start' do
      expect(subject.start).to eq "def setup\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "def setup\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  super\n"
    end
  end

  describe 'def node with args' do
    subject do
      source = "def setup(foobar)\n  do_something\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(node, 'super', adapter: adapter).process
    end

    it 'gets start' do
      expect(subject.start).to eq "def setup(foobar)\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "def setup(foobar)\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  super\n"
    end
  end

  describe 'defs node without args' do
    subject do
      source = "def self.foo\n  do_something\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(node, 'do_something_first', adapter: adapter).process
    end

    it 'gets start' do
      expect(subject.start).to eq "def self.foo\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "def self.foo\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  do_something_first\n"
    end
  end

  describe 'defs node with args' do
    subject do
      source = "def self.foo(bar)\n  do_something\nend"
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::PrependAction.new(node, 'do_something_first', adapter: adapter).process
    end

    it 'gets start' do
      expect(subject.start).to eq "def self.foo(bar)\n".length
    end

    it 'gets end' do
      expect(subject.end).to eq "def self.foo(bar)\n".length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq "  do_something_first\n"
    end
  end
end
