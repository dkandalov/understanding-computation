require 'rspec'
require_relative 'dtm'

describe 'DTM tape' do
  it 'can write to it and move head left/right' do
    tape = Tape.new(%w(1 0 1), '1', [], '_')

    expect(tape.inspect).to eq('#<Tape 101(1)>')
    expect(tape.move_head_left.inspect).to eq('#<Tape 10(1)1>')
    expect(tape.move_head_right.inspect).to eq('#<Tape 1011(_)>')
    expect(tape.move_head_right.write('0').inspect).to eq('#<Tape 1011(0)>')
  end
end

describe 'DTM rulebook' do
  it 'state changes for increment binary number rules' do
    rulebook = DTMRulebook.new(binary_increment_rules)
    tape = Tape.new(%w(1 0 1), '1', [], '_')
    configuration = TMConfiguration.new(1, tape)

    expect(configuration.inspect).to eq('#<struct TMConfiguration state=1, tape=#<Tape 101(1)>>')

    configuration = rulebook.next_configuration(configuration)
    expect(configuration.inspect).to eq('#<struct TMConfiguration state=1, tape=#<Tape 10(1)0>>')

    configuration = rulebook.next_configuration(configuration)
    expect(configuration.inspect).to eq('#<struct TMConfiguration state=1, tape=#<Tape 1(0)00>>')

    configuration = rulebook.next_configuration(configuration)
    expect(configuration.inspect).to eq('#<struct TMConfiguration state=2, tape=#<Tape 11(0)0>>')
  end
end

describe 'DTM' do
  it 'state changes for increment binary number rules' do
    rulebook = DTMRulebook.new(binary_increment_rules)
    tape = Tape.new(%w(1 0 1), '1', [], '_')
    configuration = TMConfiguration.new(1, tape)
    dtm = DTM.new(configuration, [3], rulebook)

    expect(dtm.current_configuration.inspect).to eq('#<struct TMConfiguration state=1, tape=#<Tape 101(1)>>')
    expect(dtm.accepting?).to be(false)

    dtm.step
    expect(dtm.current_configuration.inspect).to eq('#<struct TMConfiguration state=1, tape=#<Tape 10(1)0>>')
    expect(dtm.accepting?).to be(false)

    dtm.run
    expect(dtm.current_configuration.inspect).to eq('#<struct TMConfiguration state=3, tape=#<Tape 110(0)_>>')
    expect(dtm.accepting?).to be(true)
  end

  it 'handles stuck state' do
    rulebook = DTMRulebook.new(binary_increment_rules)
    tape = Tape.new(%w(1 2 1), '1', [], '_')
    dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
    dtm.run
  end
end


def binary_increment_rules
  [
      TMRule.new(1, '0', 2, '1', :right),
      TMRule.new(1, '1', 1, '0', :left),
      TMRule.new(1, '_', 2, '1', :right),
      TMRule.new(2, '0', 2, '0', :right),
      TMRule.new(2, '1', 2, '1', :right),
      TMRule.new(2, '_', 3, '_', :left)
  ]
end