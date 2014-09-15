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

  it 'empty pattern' do
    pattern = Empty.new
    expect(pattern.matches?('')).to be(true)
    expect(pattern.matches?('a')).to be(false)
  end

  it 'literal pattern' do
    pattern = Literal.new('a')
    expect(pattern.matches?('')).to be(false)
    expect(pattern.matches?('a')).to be(true)
    expect(pattern.matches?('b')).to be(false)
  end

  it 'concatenate pattern' do
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

  it 'choose patter' do
    pattern = Choose.new(Literal.new('a'), Literal.new('b'))
    expect(pattern.matches?('')).to be(false)
    expect(pattern.matches?('a')).to be(true)
    expect(pattern.matches?('b')).to be(true)
    expect(pattern.matches?('c')).to be(false)
    expect(pattern.matches?('ab')).to be(false)
  end

  it 'repeat pattern' do
    pattern = Repeat.new(Literal.new('a'))
    expect(pattern.matches?('')).to be(false)
    expect(pattern.matches?('a')).to be(true)
    expect(pattern.matches?('aaa')).to be(true)
    expect(pattern.matches?('b')).to be(false)
  end

  it 'combined patterns' do
    pattern = Repeat.new(
      Concatenate.new(
        Literal.new('a'),
        Choose.new(Empty.new, Literal.new('b'))
    ))
    expect(pattern.inspect).to eq('/(a(|b))*/')
    expect(pattern.matches?('')).to be(false)
    expect(pattern.matches?('a')).to be(true)
    expect(pattern.matches?('ab')).to be(true)
    expect(pattern.matches?('aba')).to be(true)
    expect(pattern.matches?('abaab')).to be(true)
    expect(pattern.matches?('abba')).to be(false)
  end
end