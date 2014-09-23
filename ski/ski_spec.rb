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

  it 'can reduce expressions' do
    swap = SKICall.new(SKICall.new(S, SKICall.new(K, SKICall.new(S, I))), K)
    expect(swap.to_s).to eq('S[K[S[I]]][K]')

    x, y = SKISymbol.new(:x), SKISymbol.new(:y)
    expression = SKICall.new(SKICall.new(swap, x), y)
    expect(reduce(expression).to_s)
        .to eq('[S[K[S[I]]][K][x][y], K[S[I]][x][K[x]][y], S[I][K[x]][y], I[y][K[x][y]], y[K[x][y]], y[x]]')
  end

  it 'expands and reduces S[K][I]' do
    original = SKICall.new(SKICall.new(S, K), I)
    function = original.as_a_function_of(:x)
    expect(function.to_s).to eq('S[S[K[S]][K[K]]][K[I]]')
    expect(function.reducible?).to be(false)

    y = SKISymbol.new(:y)
    expression = SKICall.new(function, y)
    expect(reduce(expression).last.to_s).to eq('S[K][I]')
  end

  # "This is explicit reimplementation of the way that variables get
  # replaced inside the body of a lambda calculus function when it's called."
  it 'expands and reduces expression replacing symbol' do
    x, y = SKISymbol.new(:x), SKISymbol.new(:y)
    original = SKICall.new(SKICall.new(S, x), I)
    expect(original.to_s).to eq('S[x][I]')

    function = original.as_a_function_of(:x)
    expect(function.to_s).to eq('S[S[K[S]][I]][K[I]]')

    expression = SKICall.new(function, y)
    expect(reduce(expression).last.to_s).to eq('S[y][I]')
  end
end