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
    rule = PDARule.new(1, '(', 2, '$', ['b', '$'])
    configuration = PDAConfiguration.new(1, Stack.new(['$']))

    expect(rule.applies_to?(configuration, '(')).to be(true)
    expect(rule.applies_to?(configuration, ')')).to be(false)
  end

  it 'can move to next configuration' do
    rule = PDARule.new(1, '(', 2, '$', ['b', '$'])
    configuration = PDAConfiguration.new(1, Stack.new(['$']))

    expect(rule.follow(configuration)).to eq(
      PDAConfiguration.new(2, Stack.new(['b', '$']))
    )
  end
end
