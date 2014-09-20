class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def step
    self.current_configuration = rulebook.next_configuration(current_configuration)
  end

  def run
    step until accepting? || stuck?
  end

  def stuck?
    !accepting? and !rulebook.applies_to?(current_configuration)
  end
end

class DTMRulebook < Struct.new(:rules)
  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end

  def applies_to?(configuration)
    not rule_for(configuration).nil?
  end
end

class TMRule < Struct.new(:state, :character, :next_state, :write_character, :direction)
  def applies_to?(configuration)
    state == configuration.state and character == configuration.tape.middle
  end

  def follow(configuration)
    TMConfiguration.new(next_state, next_tape(configuration))
  end

  def next_tape(configuration)
    written_tape = configuration.tape.write(write_character)
    case direction
      when :left
        written_tape.move_head_left
      when :right
        written_tape.move_head_right
      else
        raise("Unknown direction: #{direction}")
    end
  end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class Tape < Struct.new(:left, :middle, :right, :blank)
  def write(character)
    Tape.new(left, character, right, blank)
  end

  def move_head_left
    Tape.new(left[0..-2], left.last || blank, [middle] + right, blank)
  end

  def move_head_right
    Tape.new(left + [middle], right.first || blank, right.drop(1), blank)
  end

  def inspect
    "#<Tape #{left.join}(#{middle})#{right.join}>"
  end
end