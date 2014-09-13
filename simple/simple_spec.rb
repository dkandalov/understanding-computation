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
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    expect(expression.inspect).to eq('<<1 * 2 + 3 * 4>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce
    expect(expression.inspect).to eq('<<2 + 3 * 4>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce
    expect(expression.inspect).to eq('<<2 + 12>>')

    expect(expression.reducible?).to be(true)
    expression = expression.reduce
    expect(expression.inspect).to eq('<<14>>')

    expect(expression.reducible?).to be(false)
  end

  it 'machine' do
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
end