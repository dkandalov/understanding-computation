require 'rspec'
require_relative 'regex.rb'

describe 'Regex language' do
  it 'has AST which can be converted into string' do
    pattern = Repeat.new(
      Choose.new(
        Concatenate.new(Literal.new('a'), Literal.new('b')),
        Literal.new('a')
      )
    )
    expect(pattern.inspect).to eq('/(ab|a)*/')

    pattern = Repeat.new(
        Concatenate.new(Literal.new('a'),
          Concatenate.new(Literal.new('b'), Literal.new('c')))
    )
    expect(pattern.inspect).to eq('/(abc)*/')
  end

  it 'has NFA for empty pattern' do
    pattern = Empty.new
    expect(pattern.matches?('')).to be(true)
    expect(pattern.matches?('a')).to be(false)
  end

  it 'has NFA for literal pattern' do
    pattern = Literal.new('a')
    expect(pattern.matches?('')).to be(false)
    expect(pattern.matches?('a')).to be(true)
    expect(pattern.matches?('b')).to be(false)
  end

  it 'has NFA for concatenate pattern' do
    pattern = Concatenate.new(Literal.new('a'), Literal.new('b'))
    expect(pattern.matches?('')).to be(false)
    expect(pattern.matches?('a')).to be(false)
    expect(pattern.matches?('b')).to be(false)
    expect(pattern.matches?('ba')).to be(false)
    expect(pattern.matches?('ab')).to be(true)
    expect(pattern.matches?('abc')).to be(false)

    pattern = Concatenate.new(
       Literal.new('a'),
       Concatenate.new(Literal.new('b'), Literal.new('c'))
    )
    expect(pattern.matches?('a')).to be(false)
    expect(pattern.matches?('ab')).to be(false)
    expect(pattern.matches?('abc')).to be(true)
  end
end