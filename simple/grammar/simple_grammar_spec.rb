require 'rspec'
require 'polyglot'
require 'treetop'
require_relative '../big-step-semantics/simple'
require_relative '../denotational-semantics/simple'

describe 'simple grammar' do
  it 'should parse specific while statement' do
    Treetop.load('simple')
    parse_tree = SimpleParser.new.parse('while (x < 5) { x = x * 3 }')
    expect(parse_tree).not_to be_nil

    statement = parse_tree.to_ast
    expect(statement.evaluate({x: Number.new(1)})).to eq({x: Number.new(9)})
  end
end