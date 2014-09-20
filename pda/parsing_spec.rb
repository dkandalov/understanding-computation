require 'rspec'
require_relative 'parsing'

describe 'Lexical analyzer' do
  it 'should transform string into array of tokens for simple language' do
    tokens = LexicalAnalyzer.new('y = x * 7').analyze
    expect(tokens).to eq(%w(v = v * n))

    tokens = LexicalAnalyzer.new('while (x < 5) { x = x * 3 }').analyze
    expect(tokens).to eq(%w(w \( v < n \) { v = v * n }))

    tokens = LexicalAnalyzer.new('if (x < 10) { y = true; x = 0 } else { do-nothing }').analyze
    expect(tokens).to eq(%w(i \( v < n \) { v = b ; v = n } e { d }))

    tokens = LexicalAnalyzer.new('x = falsehood').analyze
    expect(tokens).to eq(%w(v = v))
  end
end

describe 'simple grammar validation' do
  it 'empty string' do
    expect(accepts_simple_code?('')).to be(false)
  end

  it 'while loop with assignment' do
    expect(accepts_simple_code?('while (x < 5) { x = x * 3 }')).to be(true)
  end

  it 'invalid while loop with assignment' do
    expect(accepts_simple_code?('while (x < 5 x = x * 3 }')).to be(false)
  end
end