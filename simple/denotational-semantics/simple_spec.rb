require 'rspec'
require File.expand_path('simple.rb')

describe 'Denotational semantics' do
  it 'number and boolean expressions' do
    expect(Number.new(5).to_ruby).to eq('-> e { 5 }')
    expect(Boolean.new(false).to_ruby).to eq('-> e { false }')

    expect(eval(Number.new(5).to_ruby).call({})).to eq(5)
    expect(eval(Boolean.new(false).to_ruby).call({})).to eq(false)
  end

  it 'variables' do
    expression = Variable.new(:x)
    expect(expression.to_ruby).to eq('-> e { e[:x] }')
    expect(eval(expression.to_ruby).call({x: 7})).to eq(7)
  end

  it '"add" and "less than" expressions' do
    environment = {x: 3}

    expression = Add.new(Variable.new(:x), Number.new(1))
    expect(eval(expression.to_ruby).call(environment)).to eq(4)

    expression =LessThan.new(
        Add.new(Variable.new(:x), Number.new(1)),
        Number.new(3)
    )
    expect(eval(expression.to_ruby).call(environment)).to eq(false)
  end

  it 'assign statement' do
    statement = Assign.new(:y, Add.new(Variable.new(:x), Number.new(1)))
    environment = { x: 3 }
    expect(eval(statement.to_ruby).call(environment)).to eq({ x: 3, y: 4 })
  end

  it 'while statement' do
    statement = While.new(
        LessThan.new(Variable.new(:x), Number.new(5)),
        Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
    )
    environment = { x: 1 }
    puts statement.to_ruby
    expect(eval(statement.to_ruby).call(environment)).to eq({x: 9})
  end
end