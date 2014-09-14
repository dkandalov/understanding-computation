require 'rspec'
require File.expand_path('dfa.rb')

describe 'DFA' do
  it 'should follow rules in rulebook' do
    rulebook = DFARulebook.new([
      FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
      FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
      FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
    ])

    dfa = DFA.new(1, [3], rulebook)
    expect(dfa.accepting?).to be(false)
    expect(dfa.read_string('baaab').accepting?).to be(true)

    dfa_design = DFADesign.new(1, [3], rulebook)
    expect(dfa_design.accepts?('a')).to be(false)
    expect(dfa_design.accepts?('baa')).to be(false)
    expect(dfa_design.accepts?('baba')).to be(true)
  end
end