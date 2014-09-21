require 'rspec'
require_relative 'lambda'

describe 'Lambda calculus interpreter' do
  it 'can reduce expressions' do
    increment =
      LCFunction.new(:n, LCFunction.new(:p, LCFunction.new(:x,
        LCCall.new(LCVariable.new(:p),
            LCCall.new(
              LCCall.new(LCVariable.new(:n), LCVariable.new(:p)),
              LCVariable.new(:x))
        )
      )))
    expect(increment.to_s).to eq('-> n { -> p { -> x { p[n[p][x]] } } }')

    one =
      LCFunction.new(:p, LCFunction.new(:x,
        LCCall.new(LCVariable.new(:p), LCVariable.new(:x))
      ))
    expect(one.to_s).to eq('-> p { -> x { p[x] } }')

    two = LCCall.new(increment, one)
    expect(lc_reduce(two).last.to_s)
        .to eq('-> p { -> x { p[-> p { -> x { p[x] } }[p][x]] } }') # unsimplified TWO

    inc, zero = LCVariable.new(:inc), LCVariable.new(:zero)
    expression = LCCall.new(LCCall.new(two, inc), zero)
    expect(lc_reduce(expression).last.to_s).to eq('inc[inc[zero]]')
  end

  it 'can replace variables in variables' do
    variable = LCVariable.new(:x)
    expect(variable.to_s).to eq('x')
    expect(variable.replace(:x, LCFunction.new(:y, LCVariable.new(:y))).to_s)
        .to eq('-> y { y }')
    expect(variable.replace(:z, LCFunction.new(:y, LCVariable.new(:y))).to_s)
        .to eq('x')
  end

  it 'can replace variables in calls' do
    call =
      LCCall.new(
        LCCall.new(
          LCCall.new(
            LCVariable.new(:a),
            LCVariable.new(:b)
          ),
          LCVariable.new(:c)
        ),
        LCVariable.new(:b)
      )
    expect(call.to_s).to eq('a[b][c][b]')
    expect(call.replace(:a, LCVariable.new(:x)).to_s).to eq('x[b][c][b]')
    expect(call.replace(:b, LCFunction.new(:x, LCVariable.new(:x))).to_s)
        .to eq('a[-> x { x }][c][-> x { x }]')
  end

  it 'can replace variables in functions' do
    function =
      LCFunction.new(:y,
        LCCall.new(LCVariable.new(:x), LCVariable.new(:y))
      )
    expect(function.to_s).to eq('-> y { x[y] }')
    expect(function.replace(:x, LCVariable.new(:z)).to_s).to eq('-> y { z[y] }')
    expect(function.replace(:y, LCVariable.new(:z)).to_s).to eq('-> y { x[y] }')

    expression =
      LCCall.new(
        LCCall.new(LCVariable.new(:x), LCVariable.new(:y)),
        LCFunction.new(:y, LCCall.new(LCVariable.new(:y), LCVariable.new(:x)))
      )
    expect(expression.to_s).to eq('x[y][-> y { y[x] }]')
    # both occurrences of x are replaced
    expect(expression.replace(:x, LCVariable.new(:z)).to_s).to eq('z[y][-> y { y[z] }]')
    # only one occurrence of y is replaced
    expect(expression.replace(:y, LCVariable.new(:z)).to_s).to eq('x[z][-> y { y[x] }]')
  end

  it 'replacement deficiency' do
    expression = LCFunction.new(:x, LCCall.new(LCVariable.new(:x), LCVariable.new(:y)))
    expect(expression.to_s).to eq('-> x { x[y] }')

    replacement = LCCall.new(LCVariable.new(:z), LCVariable.new(:x))
    expect(replacement.to_s).to eq('z[x]')

    # the replacement below is wrong because there is already parameter called 'x'
    expect(expression.replace(:y, replacement).to_s).to eq('-> x { x[z[x]] }')
  end

  it 'has string representation of expressions' do
    one =
      LCFunction.new(:p, LCFunction.new(:x,
          LCCall.new(LCVariable.new(:p), LCVariable.new(:x))
      ))
    expect(one.to_s).to eq('-> p { -> x { p[x] } }')
  end
end