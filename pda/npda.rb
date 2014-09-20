require_relative 'dpda'

class NPDADesign < Struct.new(:start_state, :bottom_character, :accept_states, :rulebook)
  def accepts?(string)
    to_npda.tap { |npda| npda.read_string(string) }.accepting?
  end

  def to_npda
    start_stack = Stack.new([bottom_character])
    start_configurations = Set[PDAConfiguration.new(start_state, start_stack)]
    @listener.on_state_change(start_configurations) unless @listener.nil?

    NPDA.new(start_configurations, accept_states, rulebook).with_listener(@listener)
  end

  def with_listener(listener)
    @listener = listener
    self
  end
end

class NPDA < Struct.new(:current_configurations, :accept_states, :rulebook)
  def accepting?
    current_configurations.any? { |config| accept_states.include?(config.state) }
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
    self
  end

  def read_character(character)
    self.current_configurations = rulebook.next_configurations(current_configurations, character)

    @listener.on_character(character) unless @listener.nil?
    @listener.on_state_change(self.current_configurations) unless @listener.nil?

    self
  end

  def current_configurations
    rulebook.follow_free_moves(super)
  end

  def with_listener(listener)
    @listener = listener
    self
  end
end

class NPDAListener
  def on_character(character)
  end

  def on_state_change(configurations)
  end
end

class NPDARulebook < Struct.new(:rules)
  def follow_free_moves(configurations)
    more_configurations = next_configurations(configurations, nil)

    if more_configurations.subset?(configurations)
      configurations
    else
      follow_free_moves(configurations + more_configurations)
    end
  end

  def next_configurations(configurations, character)
    configurations.flat_map{ |config| follow_rules_for(config, character) }.to_set
  end

  def follow_rules_for(configuration, character)
    rules_for(configuration, character).map { |rule| rule.follow(configuration) }
  end

  def rules_for(configuration, character)
    rules.select { |rule| rule.applies_to?(configuration, character) }
  end
end