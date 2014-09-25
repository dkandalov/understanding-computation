require 'rspec'
require_relative 'tag_system'

describe 'Tag system' do
  it 'can double a number' do
    rulebook = TagRuleBook.new(2, [TagRule.new('a', 'cc'), TagRule.new('b', 'dddd')])
    three = 'aabbbbbb'
    system = TagSystem.new(three, rulebook)

    six = 'ccdddddddddddd'
    expect(system.run).to eq(
        ['aabbbbbb', 'bbbbbbcc', 'bbbbccdddd', 'bbccdddddddd', six])
  end

  it 'can halve a number' do
    rulebook = TagRuleBook.new(2, [TagRule.new('a', 'cc'), TagRule.new('b', 'd')])
    six = 'aabbbbbbbbbbbb'
    system = TagSystem.new(six, rulebook)

    three = "ccdddddd"
    expect(system.run).to eq(
      ['aabbbbbbbbbbbb', 'bbbbbbbbbbbbcc', 'bbbbbbbbbbccd', 'bbbbbbbbccdd',
       'bbbbbbccddd', 'bbbbccdddd', 'bbccddddd', three])
  end

  it 'can increment number' do
    rulebook = TagRuleBook.new(2, [TagRule.new('a' ,'ccdd'), TagRule.new('b', 'dd')])
    two = 'aabbbb'
    system = TagSystem.new(two, rulebook)

    three = "ccdddddd"
    expect(system.run).to eq(['aabbbb', 'bbbbccdd', 'bbccdddd', three])
  end

  it 'can combine rules' do
    rulebook = TagRuleBook.new(2, [
        TagRule.new('a', 'cc'), TagRule.new('b', 'dddd'),
        TagRule.new('c', 'eeff'), TagRule.new('d', 'ff'),
    ])
    two = 'aabbbb'
    system = TagSystem.new(two, rulebook)

    five = 'eeffffffffff'
    expect(system.run.last).to eq(five)
  end

  it 'can check if number is valid on not' do
    rulebook = TagRuleBook.new(2, [
        TagRule.new('a', 'cc'), TagRule.new('b', 'd'),
        TagRule.new('c', 'eo'), TagRule.new('d', ''),
        TagRule.new('e', 'e')
    ])

    four = 'aabbbbbbbb'
    system = TagSystem.new(four, rulebook)
    expect(system.run.last).to eq('e')

    five = 'aabbbbbbbbbb'
    system = TagSystem.new(five, rulebook)
    expect(system.run.last).to eq('o')
  end
end