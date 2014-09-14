require 'set'
require File.expand_path('dfa.rb')

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map{ |state| follow_rules_for(state, character) }.to_set
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
end