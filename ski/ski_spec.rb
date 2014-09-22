require 'rspec'
require_relative 'ski'

describe 'SKI' do
  it 'has AST' do
    x = SKISymbol.new(:x)
    expression = SKICall.new(SKICall.new(S, K), SKICall.new(I, x))
    expect(expression.to_s).to eq('S[K][I[x]]')
  end

  it 'can directly reduce S' do
    x, y, z = SKISymbol.new(:x), SKISymbol.new(:y), SKISymbol.new(:z)
    expression = SKICall.new(SKICall.new(SKICall.new(S, x), y), z)
    expect(expression.to_s).to eq('S[x][y][z]')

    combinator = expression.left.left.left
    first_arg = expression.left.left.right
    second_arg = expression.left.right
    third_arg = expression.right
    result = combinator.call(first_arg, second_arg, third_arg)
    expect(result.to_s).to eq('x[z][y[z]]')
  end
end