require 'rspec'
require_relative 'dpda'

describe 'Stack' do
  it 'should have top, pop, push' do
    stack = Stack.new(%w(a b c d e))
    expect(stack.top).to eq('a')
    expect(stack.pop.pop.top).to eq('c')
    expect(stack.push('x').push('y').top).to eq('y')
    expect(stack.push('x').push('y').pop.top).to eq('x')
  end
end

describe 'PDA rule' do
  it 'knows if it applies to configuration' do
    rule = PDARule.new(1, '(', 2, '$', %w(b $))
    configuration = PDAConfiguration.new(1, Stack.new(['$']))

    expect(rule.applies_to?(configuration, '(')).to be(true)
    expect(rule.applies_to?(configuration, ')')).to be(false)
  end

  it 'can move to next configuration' do
    rule = PDARule.new(1, '(', 2, '$', %w(b $))
    configuration = PDAConfiguration.new(1, Stack.new(['$']))

    expect(rule.follow(configuration)).to eq(
      PDAConfiguration.new(2, Stack.new(%w(b $)))
    )
  end
end

describe 'DPDA rulebook' do
  it 'follows rules to move to next configuration' do
    configuration = PDAConfiguration.new(1, Stack.new(['$']))
    rulebook = DPDARulebook.new([
        PDARule.new(1, '(', 2, '$', %w(b $)),
        PDARule.new(2, '(', 2, 'b', %w(b b)),
        PDARule.new(2, ')', 2, 'b', %w()),
        PDARule.new(2, nil, 1, '$', '$')
    ])

    configuration = rulebook.next_configuration(configuration, '(')
    expect(configuration).to eq(PDAConfiguration.new(2, Stack.new(%w(b $))))

    configuration = rulebook.next_configuration(configuration, '(')
    expect(configuration).to eq(PDAConfiguration.new(2, Stack.new(%w(b b $))))

    configuration = rulebook.next_configuration(configuration, ')')
    expect(configuration).to eq(PDAConfiguration.new(2, Stack.new(%w(b $))))
  end
end

describe 'DPDA' do
  it 'determines if in accepting state after consuming characters' do
    configuration = PDAConfiguration.new(1, Stack.new(['$']))
    rulebook = DPDARulebook.new([
      PDARule.new(1, '(', 2, '$', %w(b $)),
      PDARule.new(2, '(', 2, 'b', %w(b b)),
      PDARule.new(2, ')', 2, 'b', []),
      PDARule.new(2, nil, 1, '$', ['$'])
    ])
    dpda = DPDA.new(configuration, [1], rulebook)

    expect(dpda.accepting?).to be(true)
    expect(dpda.read_string('(()(').accepting?).to be(false)
    expect(dpda.read_string('))()').accepting?).to be(true)
  end
end

describe 'DPDA design' do
  it 'determines if string is acceptable' do
    rulebook = DPDARulebook.new([
      PDARule.new(1, '(', 2, '$', %w(b $)),
      PDARule.new(2, '(', 2, 'b', %w(b b)),
      PDARule.new(2, ')', 2, 'b', []),
      PDARule.new(2, nil, 1, '$', ['$'])
    ])
    dpda_design = DPDADesign.new(1, '$', [1], rulebook)

    expect(dpda_design.accepts?('((((((()))))))')).to be(true) # ((((((()))))))
    expect(dpda_design.accepts?('()(())((()))(()(()))')).to be(true) # ()(())((()))(()(()))
    expect(dpda_design.accepts?('(()(()(()()(()()))()')).to be(false) # (()(()(()()(()()))()
  end
end

