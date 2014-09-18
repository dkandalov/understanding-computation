class DPDADesign < Struct.new(:start_state, :bottom_character, :accept_states, :rulebook)
  def accepts?(string)
    to_dpda.tap { |dpda| dpda.read_string(string) }.accepting?
  end

  def to_dpda
    stack = Stack.new([bottom_character])
    configuration = PDAConfiguration.new(start_state, stack)
    DPDA.new(configuration, accept_states, rulebook)
  end
end

class DPDA < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def read_character(character)
    self.current_configuration = next_configuration(character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character) unless stuck?
    end
    self
  end

  def current_configuration
    rulebook.follow_free_moves(super)
  end

  def stuck?
    current_configuration.stuck?
  end

  def next_configuration(character)
    if rulebook.applies_to?(current_configuration, character)
      rulebook.next_configuration(current_configuration, character)
    else
      current_configuration.stuck
    end
  end
end

class DPDARulebook < Struct.new(:rules)
  def follow_free_moves(configuration)
    if applies_to?(configuration, nil)
      follow_free_moves(next_configuration(configuration, nil))
    else
      configuration
    end
  end

  def next_configuration(configuration, character)
    rule_for(configuration, character).follow(configuration)
  end

  def applies_to?(configuration, character)
    not rule_for(configuration, character).nil?
  end

  def rule_for(configuration, character)
    rules.detect { |rule| rule.applies_to?(configuration, character) }
  end
end

class PDAConfiguration < Struct.new(:state, :stack)
  STUCK_STATE = Object.new

  def stuck
    PDAConfiguration.new(STUCK_STATE, stack)
  end

  def stuck?
    state == STUCK_STATE
  end
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