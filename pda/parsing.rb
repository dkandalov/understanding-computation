require_relative 'npda'

def accepts_simple_code?(string)
  def symbol_rule(pop, push)
    PDARule.new(2, nil, 2, pop, push)
  end

  symbol_rules = [
      # <statement> ::= <while> | <assign>
      symbol_rule('S', %w(W)),
      symbol_rule('S', %w(A)),

      # <while> ::= 'w' '(' <expression> ')' '{' <statement> '}'
      symbol_rule('W', %w(w \( E \) { S })),

      # <assign> ::= 'v' '=' <expression>
      symbol_rule('A', %w(v = E)),

      # <expression> ::= <less-than>
      symbol_rule('E', %w(L)),

      # <less-than> ::= <multiply> '<' <less-than> | <multiply>
      symbol_rule('L', %w(M < L)),
      symbol_rule('L', %w(M)),

      # <multiply> ::= <term> '*' <multiply> | <term>
      symbol_rule('M', %w(T * M)),
      symbol_rule('M', %w(T)),

      # <term> ::= 'n' | 'v'
      symbol_rule('T', %w(n)),
      symbol_rule('T', %w(v))
  ]

  token_rules = LexicalAnalyzer::GRAMMAR.map do |rule|
    PDARule.new(2, rule[:token], 2, rule[:token], [])
  end

  start_rule = PDARule.new(1, nil, 2, '$', %w(S $))
  stop_rule = PDARule.new(2, nil, 3, '$', %w($))

  rulebook = NPDARulebook.new([start_rule, stop_rule] + symbol_rules + token_rules)
  npda_design = NPDADesign.new(1, '$', [3], rulebook).with_listener(PrintingListener.new)
  token_string = LexicalAnalyzer.new(string).analyze.join
  npda_design.accepts?(token_string)
end

class PrintingListener < NPDAListener
  def on_character(character)
    puts "character: '#{character}'"
  end

  def on_state_change(configurations)
    puts 'configurations:'
    puts configurations.to_a.join("\n")
  end
end


class LexicalAnalyzer < Struct.new(:string)
  GRAMMAR = [
      { token: 'i', pattern: /if/ },
      { token: 'e', pattern: /else/ },
      { token: 'w', pattern: /while/ },
      { token: 'd', pattern: /do-nothing/ },
      { token: '(', pattern: /\(/ },
      { token: ')', pattern: /\)/ },
      { token: '{', pattern: /\{/ },
      { token: '}', pattern: /\}/ },
      { token: ';', pattern: /;/ },
      { token: '=', pattern: /=/ },
      { token: '+', pattern: /\+/ },
      { token: '*', pattern: /\*/ },
      { token: '<', pattern: /</ },
      { token: 'n', pattern: /[0-9]+/ },
      { token: 'b', pattern: /true|false/ },
      { token: 'v', pattern: /[a-z]+/ }
  ]

  def analyze
    [].tap do |tokens|
      while more_tokens?
        tokens.push(next_token)
      end
    end
  end

  private

  def more_tokens?
    !string.empty?
  end

  def next_token
    rule, match = rule_matching(string)
    self.string = string_after(match)
    rule[:token]
  end

  def rule_matching(string)
    matches = GRAMMAR.map { |rule| match_at_beginning(rule[:pattern], string) }
    rules_with_matches = GRAMMAR.zip(matches).reject { |rule, match| match.nil? }
    rule_with_longest_match(rules_with_matches)
  end

  def match_at_beginning(pattern, string)
    /\A#{pattern}/.match(string)
  end

  def rule_with_longest_match(rules_with_matches)
    rules_with_matches.max_by { |rule, match| match.to_s.length }
  end

  def string_after(match)
    match.post_match.lstrip
  end
end