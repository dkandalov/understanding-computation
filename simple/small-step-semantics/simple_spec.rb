require 'rspec'
require_relative 'simple.rb'

describe 'Simple small-step semantics' do
  it 'instantiate syntax tree' do
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    expect(expression.inspect).to eq('<<1 * 2 + 3 * 4>>')
    expect(Number.new(5).inspect).to eq('<<5>>')
  end

  it 'reduce expressions' do
    empty_environment = {}
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    expect(expression.inspect).to eq('<<1 * 2 + 3 * 4>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce(empty_environment)[0]
    expect(expression.inspect).to eq('<<2 + 3 * 4>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce(empty_environment)[0]
    expect(expression.inspect).to eq('<<2 + 12>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce(empty_environment)[0]
    expect(expression.inspect).to eq('<<14>>')

    expect(expression.reducible?).to be(false)
  end

  it 'using Machine to evaluate expressions' do
    expression = Add.new(
        Multiply.new(Number.new(1), Number.new(2)),
        Multiply.new(Number.new(3), Number.new(4))
    )
    expect{ Machine.new(expression, {}).run }.to output(
        "1 * 2 + 3 * 4\n" +
        "2 + 3 * 4\n" +
        "2 + 12\n" +
        "14\n"
    ).to_stdout
  end

  it '"less than" expression' do
    expression = LessThan.new(
      Number.new(5),
      Add.new(Number.new(2), Number.new(2))
    )
    expect{ Machine.new(expression, {}).run }.to output(
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
        "x + y, {:x=><<3>>, :y=><<4>>}\n" +
        "3 + y, {:x=><<3>>, :y=><<4>>}\n" +
        "3 + 4, {:x=><<3>>, :y=><<4>>}\n" +
        "7, {:x=><<3>>, :y=><<4>>}\n"
    ).to_stdout
  end

  it 'assignment statement' do
    machine = Machine.new(
      Assign.new(:x, Add.new(Variable.new(:x), Number.new(1))),
      {x: Number.new(2)}
    )
    expect{ machine.run }.to output(
      "x = x + 1, {:x=><<2>>}\n" +
      "x = 2 + 1, {:x=><<2>>}\n" +
      "x = 3, {:x=><<2>>}\n" +
      "do-nothing, {:x=><<3>>}\n"
    ).to_stdout
  end

  it 'if statement' do
    machine = Machine.new(
      If.new(Variable.new(:x),
        Assign.new(:y, Number.new(1)),
        Assign.new(:y, Number.new(2))
    ), {x: Boolean.new(true)})
    expect{ machine.run }.to output(
      "if (x) { y = 1 } else { y = 2 }, {:x=><<true>>}\n" +
      "if (true) { y = 1 } else { y = 2 }, {:x=><<true>>}\n" +
      "y = 1, {:x=><<true>>}\n" +
      "do-nothing, {:x=><<true>>, :y=><<1>>}\n"
    ).to_stdout

    machine = Machine.new(
      If.new(Variable.new(:x),
        Assign.new(:y, Number.new(1)),
        DoNothing.new
    ), {x: Boolean.new(false)})
    expect{ machine.run }.to output(
      "if (x) { y = 1 } else { do-nothing }, {:x=><<false>>}\n" +
      "if (false) { y = 1 } else { do-nothing }, {:x=><<false>>}\n" +
      "do-nothing, {:x=><<false>>}\n"
    ).to_stdout
  end

  it 'sequence of statements' do
    machine = Machine.new(
      Sequence.new(
        Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
        Assign.new(:y, Add.new(Variable.new(:x), Number.new(3))),
    ), {})
    expect{ machine.run }.to output(
      "x = 1 + 1; y = x + 3\n" +
      "x = 2; y = x + 3\n" +
      "do-nothing; y = x + 3, {:x=><<2>>}\n" +
      "y = x + 3, {:x=><<2>>}\n" +
      "y = 2 + 3, {:x=><<2>>}\n" +
      "y = 5, {:x=><<2>>}\n" +
      "do-nothing, {:x=><<2>>, :y=><<5>>}\n"
    ).to_stdout
  end

  it 'while statement' do
    machine = Machine.new(
      While.new(
        LessThan.new(Variable.new(:x), Number.new(5)),
        Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
    ), { x: Number.new(1) } )
    expect(machine.run).to eq({x: Number.new(9)})
  end
end