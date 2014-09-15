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

  it 'has NFA for empty pattern' do
    empty = Empty.new
    expect(empty.matches?('')).to be(true)
    expect(empty.matches?('a')).to be(false)
  end

  it 'has NFA for literal pattern' do
    literal = Literal.new('a')
    expect(literal.matches?('')).to be(false)
    expect(literal.matches?('a')).to be(true)
    expect(literal.matches?('b')).to be(false)
  end
end