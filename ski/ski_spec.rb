require 'rspec'
require 'polyglot'
require 'treetop'
require_relative 'ski'
require_relative '../lambda/lambda'

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

  it 'behaves like function calls in lambda calculus' do
    Treetop.load('../lambda/grammar/lambda_calculus')
    two = LambdaCalculusParser.new.parse('-> p { -> x { p[p[x]] } }').to_ast
    expect(two.to_s).to eq('-> p { -> x { p[p[x]] } }')
    expect(two.to_ski.to_s).to eq('S[S[K[S]][S[K[K]][I]]][S[S[K[S]][S[K[K]][I]]][K[I]]]')

    inc, zero = SKISymbol.new(:inc), SKISymbol.new(:zero)
    expression = SKICall.new(SKICall.new(two.to_ski, inc), zero)
    expect(reduce(expression).last.to_s).to eq('inc[inc[zero]]')
  end

  it 'I combinator is redundant' do
    x = SKISymbol.new(:x)
    identity = SKICall.new(SKICall.new(S, K), K)
    expression = SKICall.new(identity, x)

    expect(expression.to_s).to eq('S[K][K][x]')
    expect(reduce(expression).to_s).to eq('[S[K][K][x], K[x][K[x]], x]')
  end

  it 'ι version of S' do
    expression = S.to_iota
    expect(reduce(expression).last.to_s).to eq('S')
  end

  it 'ι version of K' do
    expression = K.to_iota
    expect(reduce(expression).last.to_s).to eq('K')
  end

  it 'ι version of I' do
    expression = I.to_iota
    identity = reduce(expression).last
    expect(identity.to_s).to eq('S[K][K[K]]')

    x = SKISymbol.new(:x)
    expression = SKICall.new(identity, x)
    expect(reduce(expression).last.to_s).equal?('x')
  end

  it 'two in ι' do
    Treetop.load('../lambda/grammar/lambda_calculus')
    two = LambdaCalculusParser.new.parse('-> p { -> x { p[p[x]] } }').to_ast.to_ski.to_iota
    expect(two.to_s).to eq('ι[ι[ι[ι[ι]]]][ι[ι[ι[ι[ι]]]][ι[ι[ι[ι]]][ι[ι[ι[ι[ι]]]]]]' +
                              '[ι[ι[ι[ι[ι]]]][ι[ι[ι[ι]]][ι[ι[ι[ι]]]]][ι[ι]]]][ι[ι[ι[ι[ι]]]]' +
                              '[ι[ι[ι[ι[ι]]]][ι[ι[ι[ι]]][ι[ι[ι[ι[ι]]]]]][ι[ι[ι[ι[ι]]]][ι[ι[ι[ι]]]' +
                              '[ι[ι[ι[ι]]]]][ι[ι]]]][ι[ι[ι[ι]]][ι[ι]]]]')

    inc, zero = SKISymbol.new(:inc), SKISymbol.new(:zero)
    expression = SKICall.new(SKICall.new(two, inc), zero)

    expect(reduce(expression).last.to_s).to eq('inc[inc[zero]]')
  end
end