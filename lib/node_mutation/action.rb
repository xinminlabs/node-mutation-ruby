# frozen_string_literal: true

# Action defines rewriter action, insert, replace or delete code.
class NodeMutation::Action
  # @!attribute [rw] start
  #   @return [Integer] start position
  # @!attribute [rw] end
  #   @return [Integer] end position
  # @!attribute [rw] type
  #   @return [Symbol] action type, :insert, :replace or :delete
  # @!attribute [rw] actions
  #   @return [Array<NodeMutation::Action>] child actions
  attr_accessor :start, :end, :type, :actions

  # Initialize an action.
  #
  # @param node [Node]
  # @param code [String] new code to insert, replace or delete.
  # @param adapter [NodeMutation::Adapter]
  def initialize(node, code, adapter:)
    @node = node
    @code = code
    @adapter = adapter
  end

  # Calculate begin and end positions, and return self.
  #
  # @return [NodeMutation::Action] self
  def process
    calculate_position
    self
  end

  def to_struct
    to_struct_actions = @actions ? @actions.map(&:to_struct) : nil
    NodeMutation::Struct::Action.new(@type, @start, @end, new_code, to_struct_actions)
  end

  protected

  # Calculate the begin the end positions.
  #
  # @abstract
  def calculate_position
    raise NotImplementedError, 'must be implemented by subclasses'
  end

  # The rewritten source code.
  #
  # @return [String] rewritten source code.
  def rewritten_source
    @rewritten_source ||= @adapter.rewritten_source(@node, @code)
  end

  # remove unused whitespace.
  # e.g. `%i[foo bar]`, if we remove `foo`, the whitespace should also be removed,
  # the code should be changed to `%i[bar]`.
  def remove_whitespace
    if file_source[@start - 1] == ' ' && file_source[@end] == ' '
      @start -= 1
      @end += 1 if file_source[@end + 1].nil?
      return
    end

    if ["\n", ';', ')', ']', '}', '|', nil].include?(file_source[@end]) && file_source[@start - 1] == ' '
      @start -= 1
      return
    end

    if ['(', '[', '{', '|'].include?(file_source[@start - 1]) && file_source[@end] == ' '
      @end += 1
    end
  end

  # Remove unused comma.
  # e.g. `foobar(foo, bar)`, if we remove `foo`, the comma should also be removed,
  # the code should be changed to `foobar(bar)`.
  def remove_comma
    leading_count = 1
    loop do
      if file_source[@start - leading_count] == ','
        @start -= leading_count
        return
      elsif ["\n", "\r", "\t", ' '].include?(file_source[@start - leading_count])
        leading_count += 1
      else
        break
      end
    end

    trailing_count = 0
    loop do
      if file_source[@end + trailing_count] == ','
        @end += trailing_count + 1
        return
      elsif file_source[@end + trailing_count] == ' '
        trailing_count += 1
      else
        break
      end
    end
  end

  # Return file source.
  #
  # @return [String]
  def file_source
    @file_source ||= @adapter.file_source(@node)
  end
end
