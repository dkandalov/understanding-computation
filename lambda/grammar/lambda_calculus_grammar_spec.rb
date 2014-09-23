require 'rspec'
require 'polyglot'
require 'treetop'
require_relative '../lambda'

describe 'lambda calculus grammar' do
  it 'should parse expression' do
    Treetop.load('lambda_calculus')
    parse_tree = LambdaCalculusParser.new.parse('-> x { x[x] }[-> y { y }]')
    expect(parse_tree).not_to be_nil

    expression = parse_tree.to_ast
    expect(expression.to_s).to eq('-> x { x[x] }[-> y { y }]')
    expect(expression.reduce.to_s).to eq('-> y { y }[-> y { y }]')
  end
end