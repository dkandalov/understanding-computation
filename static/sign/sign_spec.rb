require 'rspec'
require_relative 'sign'

describe 'signs' do
  it 'can be multiplied' do
    expect(Sign::POSITIVE * Sign::POSITIVE).to eq(Sign::POSITIVE)
    expect(Sign::NEGATIVE * Sign::ZERO).to eq(Sign::ZERO)
    expect(Sign::POSITIVE * Sign::NEGATIVE).to eq(Sign::NEGATIVE)
  end

  it 'can be added' do
    expect(Sign::POSITIVE + Sign::POSITIVE).to eq(Sign::POSITIVE)
    expect(Sign::NEGATIVE + Sign::ZERO).to eq(Sign::NEGATIVE)
    expect(Sign::NEGATIVE + Sign::POSITIVE).to eq(Sign::UNKNOWN)
  end

  it 'can be converted from numbers' do
    expect(6.sign).to eq(Sign::POSITIVE)
    expect(-9.sign).to eq(Sign::NEGATIVE)
    expect(6.sign * -9.sign).to eq(Sign::NEGATIVE)
  end

  it 'determines if it "fits" within another sign' do
    expect(Sign::POSITIVE <= Sign::POSITIVE).to be(true)
    expect(Sign::POSITIVE <= Sign::UNKNOWN).to be(true)
    expect(Sign::POSITIVE <= Sign::NEGATIVE).to be(false)

    expect((6 * -9).sign <= (6.sign * -9.sign)).to be(true)
    expect((-5 + 0).sign <= (-5.sign + 0.sign)).to be(true)
    expect((6 + -9).sign <= (6.sign + -9.sign)).to be(true)
  end

  def sum_of_squares(x, y)
    (x * x) + (y * y)
  end

  it 'can analyze result of sum of squares' do
    inputs = Sign::NEGATIVE, Sign::ZERO, Sign::NEGATIVE
    outputs = inputs.product(inputs).map { |x, y| sum_of_squares(x, y) }.uniq
    expect(outputs).to eq([Sign::POSITIVE, Sign::ZERO])
  end
end