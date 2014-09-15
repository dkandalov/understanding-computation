require 'rspec'
require_relative 'nfa.rb'

describe 'NFA' do
  it 'determine if in accepting state' do
    some_rulebook = NFARulebook.new([])
    expect(NFA.new(Set[1], [4], some_rulebook).accepting?).to be(false)
    expect(NFA.new(Set[1, 2, 4], [4], some_rulebook).accepting?).to be(true)
  end

  it 'should follow rules (see also nfa.png)' do
    rulebook = NFARulebook.new([
      FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
      FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
      FARule.new(3, 'a', 4), FARule.new(3, 'b', 4)
    ])

    nfa = NFA.new(Set[1], [4], rulebook)
    expect(nfa.accepting?).to be(false)
    expect(nfa.read_character('b').accepting?).to be(false)
    expect(nfa.read_character('a').accepting?).to be(false)
    expect(nfa.read_character('b').accepting?).to be(true)

    nfa = NFA.new(Set[1], [4], rulebook)
    expect(nfa.read_string('bbb').accepting?).to be(true)

    nfa_design = NFADesign.new(1, [4], rulebook)
    expect(nfa_design.accepts?('bab')).to be(true)
    expect(nfa_design.accepts?('bbbbb')).to be(true)
    expect(nfa_design.accepts?('bbabb')).to be(false)
  end

  it 'should follow rules with free moves (see also nfr_free_moves.png)' do
    rulebook = NFARulebook.new([
      FARule.new(1, nil, 2), FARule.new(1, nil, 4),
      FARule.new(2, 'a', 3), FARule.new(3, 'a', 2),
      FARule.new(4, 'a', 5), FARule.new(5, 'a', 6),
      FARule.new(6, 'a', 4)
    ])
    nfa_design = NFADesign.new(1, [2, 4], rulebook)
    expect(nfa_design.accepts?('aa')).to be(true)
    expect(nfa_design.accepts?('aaa')).to be(true)
    expect(nfa_design.accepts?('aaaaa')).to be(false)
  end
end
