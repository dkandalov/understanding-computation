require 'rspec'
require File.expand_path('simple.rb')

describe 'Simple big-step semantics' do
  it 'basic expressions evaluation' do
    expect(Number.new(23).evaluate({}).inspect).to eq('<<23>>')
    expect(Variable.new(:x).evaluate({x: Number.new(23)}).inspect).to eq('<<23>>')

    expression = LessThan.new(
      Add.new(Variable.new(:x), Number.new(2)),
      Variable.new(:y)
    )
    environment = {x: Number.new(2), y: Number.new(5)}
    expect(expression.evaluate(environment).inspect).to eq('<<true>>')
  end

  it 'sequence statement' do
    statement = Sequence.new(
      Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
      Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
    )
    expect(statement.evaluate({})).to eq({ x: Number.new(2), y: Number.new(5) })
  end

  it 'while statement' do
    statement = While.new(
        LessThan.new(Variable.new(:x), Number.new(5)),
        Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
    )
    environment = { x: Number.new(1) }
    expect(statement.evaluate(environment)).to eq({x: Number.new(9)})
  end

end