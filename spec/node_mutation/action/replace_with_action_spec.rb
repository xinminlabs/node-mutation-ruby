# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NodeMutation::ReplaceWithAction do
  let(:adapter) { NodeMutation::ParserAdapter.new }

  context 'replace with single line' do
    subject {
      source = 'post = FactoryGirl.create_list :post, 2'
      node = Parser::CurrentRuby.parse(source).children[1]
      NodeMutation::ReplaceWithAction.new(node, 'create_list {{arguments}}', adapter: adapter).process
    }

    it 'gets start' do
      expect(subject.start).to eq 'post = '.length
    end

    it 'gets end' do
      expect(subject.end).to eq 'post = FactoryGirl.create_list :post, 2'.length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq 'create_list :post, 2'
    end
  end

  context '#replace with multiple line' do
    subject {
      source = '  its(:size) { should == 1 }'
      node = Parser::CurrentRuby.parse(source)
      NodeMutation::ReplaceWithAction.new(node, <<~EOS, adapter: adapter).process
        describe '#size' do
          subject { super().size }
          it { {{body}} }
        end
      EOS
    }

    it 'gets start' do
      expect(subject.start).to eq 2
    end

    it 'gets end' do
      expect(subject.end).to eq '  its(:size) { should == 1 }'.length
    end

    it 'gets new_code' do
      expect(subject.new_code).to eq <<~EOS.strip
        describe '#size' do
            subject { super().size }
            it { should == 1 }
          end
      EOS
    end
  end
end
