require 'rspec'
require File.expand_path('nfa.rb')

describe 'NFA' do
  it 'should follow rules' do
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
  end

  it 'determine if in accepting state' do
    some_rulebook = NFARulebook.new([])
    expect(NFA.new([1], [4], some_rulebook).accepting?).to be(false)
    expect(NFA.new([1, 2, 4], [4], some_rulebook).accepting?).to be(true)
  end
end
