class TagRule < Struct.new(:first_character, :append_character)
  def applies_to?(string)
    string.chars.first == first_character
  end

  def follow(string)
    string + append_character
  end
end

class TagRuleBook < Struct.new(:deletion_number, :rules)
  def applies_to?(string)
    !rule_for(string).nil? && string.length >= deletion_number
  end

  def next_string(string)
    rule_for(string).follow(string).slice(deletion_number..-1)
  end

  def rule_for(string)
    rules.detect { |r| r.applies_to?(string) }
  end
end

class TagSystem < Struct.new(:current_string, :rulebook)
  def run
    steps = []
    while rulebook.applies_to?(current_string)
      steps.push(current_string)
      step
    end
    steps.push(current_string)
    steps
  end

  def step
    self.current_string = rulebook.next_string(current_string)
  end
end