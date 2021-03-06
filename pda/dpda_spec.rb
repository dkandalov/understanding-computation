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

  it 'can handle stuck state' do
    rulebook = DPDARulebook.new([
      PDARule.new(1, '(', 2, '$', %w(b $)),
      PDARule.new(2, '(', 2, 'b', %w(b b)),
      PDARule.new(2, ')', 2, 'b', []),
      PDARule.new(2, nil, 1, '$', ['$'])
    ])

    dpda_design = DPDADesign.new(1, '$', [1], rulebook)
    expect(dpda_design.accepts?('())')).to be(false)

    dpda = dpda_design.to_dpda
    dpda.read_string('())')
    expect(dpda.accepting?).to be(false)
    expect(dpda.stuck?).to be(true)
  end

  it 'can recognize strings containing equal number of a and b' do
    rules = [
        PDARule.new(1, 'a', 2, '$', %w(a $)),
        PDARule.new(1, 'b', 2, '$', %w(b $)),
        PDARule.new(2, 'a', 2, 'a', %w(a a)),
        PDARule.new(2, 'b', 2, 'b', %w(b b)),
        PDARule.new(2, 'a', 2, 'b', []),
        PDARule.new(2, 'b', 2, 'a', []),
        PDARule.new(2, nil, 1, '$', ['$'])
    ]
    rulebook = DPDARulebook.new(rules)
    dpda_design = DPDADesign.new(1, '$', [1], rulebook)

    expect(dpda_design.accepts?('ababab')).to be(true)
    expect(dpda_design.accepts?('bbbaaaab')).to be(true)
    expect(dpda_design.accepts?('baa')).to be(false)
  end

  it 'can recognize palindrome made from a and b' do
    rules = [
        PDARule.new(1, 'a', 1, '$', %w(a $)),
        PDARule.new(1, 'a', 1, 'a', %w(a a)),
        PDARule.new(1, 'a', 1, 'b', %w(a b)),
        PDARule.new(1, 'b', 1, '$', %w(b $)),
        PDARule.new(1, 'b', 1, 'a', %w(b a)),
        PDARule.new(1, 'b', 1, 'b', %w(b b)),
        PDARule.new(1, 'm', 2, '$', ['$']),
        PDARule.new(1, 'm', 2, 'a', ['a']),
        PDARule.new(1, 'm', 2, 'b', ['b']),
        PDARule.new(2, 'a', 2, 'a', []),
        PDARule.new(2, 'b', 2, 'b', []),
        PDARule.new(2, nil, 3, '$', ['$'])
    ]
    dpda_design = DPDADesign.new(1, '$', [3], DPDARulebook.new(rules))

    expect(dpda_design.accepts?('ama')).to be(true)
    expect(dpda_design.accepts?('abmba')).to be(true)
    expect(dpda_design.accepts?('babbamabbab')).to be(true)
    expect(dpda_design.accepts?('abmb')).to be(false)
    expect(dpda_design.accepts?('baambaa')).to be(false)
  end
end

