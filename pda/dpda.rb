class PDAConfiguration < Struct.new(:state, :stack)
end

class PDARule < Struct.new(:state, :character, :next_state,
                           :pop_character, :push_characters)
  def follow(configuration)
    PDAConfiguration.new(next_state, next_stack(configuration))
  end

  def next_stack(configuration)
    popped_stack = configuration.stack.pop
    push_characters.reverse.inject(popped_stack) do |stack, character|
      stack.push(character)
    end
  end

  def applies_to?(configuration, character)
    self.state == configuration.state and
      self.pop_character == configuration.stack.top and
      self.character == character
  end
end

class Stack < Struct.new(:contents)
  def push(character)
    Stack.new([character] + contents)
  end

  def pop
    Stack.new(contents.drop(1))
  end

  def top
    contents.first
  end

  def inspect
    "#<Stack (#{top})#{contents.drop(1).join}"
  end
end