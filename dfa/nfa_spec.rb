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

describe 'NFA to DFA conversion' do
  it 'next steps can be simulated' do
    rulebook = NFARulebook.new([
       FARule.new(1, 'a', 1), FARule.new(1, 'a', 2), FARule.new(1, nil, 2),
       FARule.new(2, 'b', 3),
       FARule.new(3, 'b', 1), FARule.new(3, nil, 2)
    ])
    nfa_design = NFADesign.new(1, [3], rulebook)
    simulation = NFASimulation.new(nfa_design)

    expect(simulation.next_state(Set[1, 2], 'a')).to eq(Set[1, 2])
    expect(simulation.next_state(Set[1, 2], 'b')).to eq(Set[2, 3])
    expect(simulation.next_state(Set[3, 2], 'b')).to eq(Set[1, 3, 2])
    expect(simulation.next_state(Set[1, 3, 2], 'b')).to eq(Set[1, 3, 2])
    expect(simulation.next_state(Set[1, 3, 2], 'a')).to eq(Set[1, 2])
  end

  it 'rules can be found for any state' do
    rulebook = NFARulebook.new([
       FARule.new(1, 'a', 1), FARule.new(1, 'a', 2), FARule.new(1, nil, 2),
       FARule.new(2, 'b', 3),
       FARule.new(3, 'b', 1), FARule.new(3, nil, 2)
    ])
    nfa_design = NFADesign.new(1, [3], rulebook)
    simulation = NFASimulation.new(nfa_design)

    expect(rulebook.alphabet).to eq(['a', 'b'])
    expect(simulation.rules_for(Set[1, 2])).to eq([
      FARule.new(Set[1, 2], 'a', Set[1, 2]),
      FARule.new(Set[1, 2], 'b', Set[3, 2]),
    ])
    expect(simulation.rules_for(Set[3, 2])).to eq([
      FARule.new(Set[3, 2], 'a', Set[]),
      FARule.new(Set[3, 2], 'b', Set[1, 3, 2]),
    ])
  end

  it 'output DFA works same way as NFA' do
    rulebook = NFARulebook.new([
       FARule.new(1, 'a', 1), FARule.new(1, 'a', 2), FARule.new(1, nil, 2),
       FARule.new(2, 'b', 3),
       FARule.new(3, 'b', 1), FARule.new(3, nil, 2)
    ])
    nfa_design = NFADesign.new(1, [3], rulebook)
    simulation = NFASimulation.new(nfa_design)

    dfa_design = simulation.to_dfa_design

    expect(dfa_design.accepts?('aaa')).to be(false)
    expect(dfa_design.accepts?('aab')).to be(true)
    expect(dfa_design.accepts?('bbbabb')).to be(true)
  end
end

