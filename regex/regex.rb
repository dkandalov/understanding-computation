require_relative '../dfa/nfa'

module Pattern
  def matches?(string)
    to_nfa_design.accepts?(string)
  end

  def bracket(outer_precedence)
    if precedence < outer_precedence
      '(' + to_s + ')'
    else
      to_s
    end
  end

  def inspect
    "/#{self}/"
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern

  def to_nfa_design
    nfa = pattern.to_nfa_design

    extra_rules = nfa.accept_states.map do |it|
      FARule.new(it, nil, nfa.start_state)
    end
    rulebook = NFARulebook.new(nfa.rulebook.rules + extra_rules)

    NFADesign.new(nfa.start_state, nfa.accept_states, rulebook)
  end

  def to_s
    pattern.bracket(precedence) + '*'
  end

  def precedence
    2
  end
end

class Choose < Struct.new(:first, :second)
  include Pattern

  def to_nfa_design
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design

    start_state = Object.new
    accept_states = first_nfa_design.accept_states + second_nfa_design.accept_states

    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    extra_rules = [first_nfa_design, second_nfa_design].map do |nfa_design|
      FARule.new(start_state, nil, nfa_design.start_state)
    end
    rulebook = NFARulebook.new(rules + extra_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end

  def to_s
    [first, second].map { |it| it.bracket(precedence) }.join('|')
  end

  def precedence
    0
  end
end

class Concatenate < Struct.new(:first, :second)
  include Pattern

  def to_nfa_design
    first_nfa_design = first.to_nfa_design
    second_nfa_design = second.to_nfa_design

    rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
    extra_rules = first_nfa_design.accept_states.map{ |state|
      FARule.new(state, nil, second_nfa_design.start_state)
    }
    rulebook = NFARulebook.new(rules + extra_rules)

    start_state = first_nfa_design.start_state
    accept_states = second_nfa_design.accept_states
    NFADesign.new(start_state, accept_states, rulebook)
  end

  def to_s
    [first, second].map { |it| it.bracket(precedence) }.join
  end

  def precedence
    1
  end
end

class Literal < Struct.new(:character)
  include Pattern

  def to_nfa_design
    start_state = Object.new
    accept_state = Object.new
    rulebook = NFARulebook.new([
      FARule.new(start_state, character, accept_state)
    ])
    NFADesign.new(start_state, [accept_state], rulebook)
  end

  def to_s
    character
  end

  def precedence
    3
  end
end

class Empty
  include Pattern

  def to_nfa_design
    start_state = Object.new
    accept_states = [start_state]
    rulebook = NFARulebook.new([])
    NFADesign.new(start_state, accept_states, rulebook)
  end

  def to_s
    ''
  end

  def precedence
    3
  end
end