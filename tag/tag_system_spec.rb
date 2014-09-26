require 'rspec'
require 'rspec/core/example_group'
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

    three = 'ccdddddd'
    expect(system.run).to eq(
      ['aabbbbbbbbbbbb', 'bbbbbbbbbbbbcc', 'bbbbbbbbbbccd', 'bbbbbbbbccdd',
       'bbbbbbccddd', 'bbbbccdddd', 'bbccddddd', three])
  end

  it 'can increment number' do
    three = 'ccdddddd'
    expect(inc_system.run).to eq(['aabbbb', 'bbbbccdd', 'bbccdddd', three])
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

  it 'has alphabet' do
    rulebook = TagRuleBook.new(2, [TagRule.new('a' ,'ccdd'), TagRule.new('b', 'dd')])
    system = TagSystem.new('aabbbb', rulebook)

    expect(system.alphabet).to eq(%w(a b c d))
  end

  it 'can encode characters for cyclic tag system' do
    expect(inc_system.encoder.encode_string('cab')).to eq('001010000100')
  end

  it 'can be converted to cyclic tag system' do
    cyclic_system = inc_system.to_cyclic
    expect(cyclic_system.run.last(5)).to eq(['0001', '001', '01', '1', ''])
  end

  let(:inc_system) do
    rulebook = TagRuleBook.new(2, [TagRule.new('a' ,'ccdd'), TagRule.new('b', 'dd')])
    two = 'aabbbb'
    TagSystem.new(two, rulebook)
  end
end

describe 'Cyclic tag system' do
  it 'can stabilize to a repetitive behavior' do
    rules = [CyclicTagRule.new('1'), CyclicTagRule.new('0010'), CyclicTagRule.new('10')]
    rulebook = CyclicTagRuleBook.new(rules)
    system = TagSystem.new('11', rulebook)

    pattern = %w(0101 101 011 11 110 101 010010 10010 00101)
    expect(system.run(43)).to eq([
       '11', '11', '10010', '001010', '01010', '1010',
       '01010', '1010', '0100010', '100010', '000101',
       '00101', '0101', '101', '010010', '10010', '00101',
       pattern, pattern, pattern
    ].flatten)
  end
end
