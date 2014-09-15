require 'set'
require_relative './dfa.rb'

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map{ |state| follow_rules_for(state, character) }.to_set
  end

  def follow_free_moves(states)
    more_states = next_states(states, nil)
    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end

  private

  def follow_rules_for(state, character)
    rules
      .select{ |rule| rule.applies_to?(state, character) }
      .map(&:follow)
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def read_string(string)
    string.chars.each{ |char| read_character(char) }
    self
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
    self
  end

  def accepting?
    (current_states & accept_states).any?
  end

  def current_states
    rulebook.follow_free_moves(super)
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepts?(string)
    to_nfa.tap{ |nfa| nfa.read_string(string) }.accepting?
  end

  def to_nfa
    NFA.new(Set[start_state], accept_states, rulebook)
  end
end