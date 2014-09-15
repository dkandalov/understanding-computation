require 'rspec'
require_relative 'regex.rb'

describe 'Regex language' do
  it 'has AST which can be converted into string' do
    regex = Repeat.new(
      Choose.new(
        Concatenate.new(Literal.new('a'), Literal.new('b')),
        Literal.new('a')
      )
    )
    expect(regex.inspect).to eq('/(ab|a)*/')

    regex = Repeat.new(
        Concatenate.new(Literal.new('a'),
          Concatenate.new(Literal.new('b'), Literal.new('c')))
    )
    expect(regex.inspect).to eq('/(abc)*/')
  end
end