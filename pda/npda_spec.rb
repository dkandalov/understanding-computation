require_relative 'npda'
require 'rspec'

describe 'NPDA' do
  it 'accepts palindromes' do
    rules = [
        PDARule.new(1, 'a', 1, '$', %w(a $)),
        PDARule.new(1, 'a', 1, 'a', %w(a a)),
        PDARule.new(1, 'a', 1, 'b', %w(a b)),
        PDARule.new(1, 'b', 1, '$', %w(b $)),
        PDARule.new(1, 'b', 1, 'a', %w(b a)),
        PDARule.new(1, 'b', 1, 'b', %w(b b)),
        PDARule.new(1, nil, 2, '$', ['$']),
        PDARule.new(1, nil, 2, 'a', ['a']),
        PDARule.new(1, nil, 2, 'b', ['b']),
        PDARule.new(2, 'a', 2, 'a', []),
        PDARule.new(2, 'b', 2, 'b', []),
        PDARule.new(2, nil, 3, '$', ['$'])
    ]
    rulebook = NPDARulebook.new(rules)
    npda_design = NPDADesign.new(1, '$', [3], rulebook)

    expect(npda_design.accepts?('abba')).to be(true)
    expect(npda_design.accepts?('babbaabbab')).to be(true)
    expect(npda_design.accepts?('abb')).to be(false)
    expect(npda_design.accepts?('baabaa')).to be(false)
  end
end