require 'rspec'
require File.expand_path('simple.rb')

describe 'Simple language' do
  it 'instantiate syntax tree' do
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    expect(expression.inspect).to eq('<<1 * 2 + 3 * 4>>')
    expect(Number.new(5).inspect).to eq('<<5>>')
  end

  it 'reduce expressions in small steps' do
    empty_environment = {}
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    expect(expression.inspect).to eq('<<1 * 2 + 3 * 4>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce(empty_environment)
    expect(expression.inspect).to eq('<<2 + 3 * 4>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce(empty_environment)
    expect(expression.inspect).to eq('<<2 + 12>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce(empty_environment)
    expect(expression.inspect).to eq('<<14>>')

    expect(expression.reducible?).to be(false)
  end

  it 'using Machine to evaluate expressions' do
    expression = Add.new(
        Multiply.new(Number.new(1), Number.new(2)),
        Multiply.new(Number.new(3), Number.new(4))
    )
    expect{ Machine.new(expression).run }.to output(
        "1 * 2 + 3 * 4\n" +
        "2 + 3 * 4\n" +
        "2 + 12\n" +
        "14\n"
    ).to_stdout
  end

  it '"left than" expression' do
    expression = LessThan.new(
      Number.new(5),
      Add.new(Number.new(2), Number.new(2))
    )
    expect{ Machine.new(expression).run }.to output(
        "5 < 2 + 2\n" +
        "5 < 4\n" +
        "false\n"
    ).to_stdout
  end

  it 'expression with variable' do
    machine = Machine.new(
      Add.new(Variable.new(:x), Variable.new(:y)),
      { x: Number.new(3), y: Number.new(4) }
    )
    expect{ machine.run }.to output(
        "x + y\n" +
        "3 + y\n" +
        "3 + 4\n" +
        "7\n"
    ).to_stdout
  end
end