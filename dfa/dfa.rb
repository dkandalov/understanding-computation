class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state && self.character == character
  end

  def follow
    next_state
  end

  def inspect
    "#<FARule #{state.inspect} --#{character.inspect}--> #{next_state.inspect}>"
  end
end

class DFARulebook < Struct.new(:rules)
  def next_state(state, character)
    rule_for(state, character).follow
  end

  def rule_for(state, character)
    rules.detect { |it| it.applies_to?(state, character) }
  end
end

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
  def read_string(string)
    string.chars.each do |char|
      read_character(char)
    end
    self
  end

  def read_character(character)
    self.current_state = rulebook.next_state(current_state, character)
  end

  def accepting?
    accept_states.include?(current_state)
  end
end

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepts?(string)
    to_dfa.tap{ |dfa| dfa.read_string(string) }.accepting?
  end

  def to_dfa
    DFA.new(start_state, accept_states, rulebook)
  end
end