require 'rspec'
require_relative 'simple_types'

describe 'Simple types' do
  it 'can be applied to basic expressions' do
    context = {}

    expression = Add.new(Number.new(1), Number.new(2))
    expect(expression.type(context)).to eq(Type::NUMBER)

    expression = Add.new(Number.new(1), Boolean.new(2))
    expect(expression.type(context)).to eq(nil)

    expression = LessThan.new(Number.new(1), Number.new(2))
    expect(expression.type(context)).to eq(Type::BOOLEAN)

    expression = LessThan.new(Number.new(1), Boolean.new(true))
    expect(expression.type(context)).to eq(nil)
  end

  it 'can be applied to expressions with variables' do
    expression = Add.new(Variable.new(:x), Variable.new(:y))

    context = {}
    expect(expression.type(context)).to eq(nil)

    context = {x: Type::NUMBER, y: Type::NUMBER}
    expect(expression.type(context)).to eq(Type::NUMBER)

    context = {x: Type::NUMBER, y: Type::BOOLEAN}
    expect(expression.type(context)).to eq(nil)
  end

  it 'can be applied to statements' do
    statement = While.new(
       LessThan.new(Variable.new(:x), Number.new(5)),
       Assign.new(:x, Add.new(Variable.new(:x), Number.new(3)))
    )

    context = {}
    expect(statement.type(context)).to eq(nil)

    context = {x: Type::NUMBER}
    expect(statement.type(context)).to eq(Type::VOID)

    context = {x: Type::BOOLEAN}
    expect(statement.type(context)).to eq(nil)
  end
end