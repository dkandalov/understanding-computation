class Machine < Struct.new(:statement, :environment)
  def step
    self.statement, self.environment = statement.reduce(environment)
  end

  def run
    while statement.reducible?
      print_state
      step
    end
    print_state
    environment
  end

  def print_state
    if environment.nil? or environment.empty?
      puts statement
    else
      puts "#{statement}, #{environment}"
    end
  end
end

class While < Struct.new(:condition, :body)
  def reduce(environment)
    [If.new(condition, Sequence.new(body, self), DoNothing.new), environment]
  end

  def reducible?
    true
  end

  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "<<#{self}>>"
  end
end

class Sequence < Struct.new(:first, :second)
  def reduce(environment)
    case first
      when DoNothing.new
        [second, environment]
      else
        reduced_first, environment = first.reduce(environment)
        [Sequence.new(reduced_first, second), environment]
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{first}; #{second}"
  end

  def inspect
    "<<#{self}>>"
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def reduce(environment)
    if condition.reducible?
      reduced_condition, environment = condition.reduce(environment)
      [If.new(reduced_condition, consequence, alternative), environment]
    else
      case condition
        when Boolean.new(true)
          [consequence, environment]
        when Boolean.new(false)
          [alternative, environment]
        else
          raise("Unsupported condition: #{condition}")
      end
    end
  end

  def reducible?
    true
  end

  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "<<#{self}>>"
  end
end

class Assign < Struct.new(:name, :expression)
  def reduce(environment)
    if expression.reducible?
      reduced_expression, environment = expression.reduce(environment)
      [Assign.new(name, reduced_expression), environment]
    else
      [DoNothing.new, environment.merge({name => expression})]
    end
  end

  def reducible?
    true
  end

def to_s
  "#{name} = #{expression}"
end

  def inspect
    "<<#{self}>>"
  end
end

class DoNothing
  def reducible?
    false
  end

  def to_s
    'do-nothing'
  end

  def inspect
    "<<#{self}>>"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end
end

class Variable < Struct.new(:name)
  def reduce(environment)
    [environment[name], environment]
  end

  def reducible?
    true
  end

  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end
end

class Boolean < Struct.new(:value)
  def reducible?
    false
  end

  def to_s
    "#{value}"
  end

  def inspect
    "<<#{self}>>"
  end
end

class LessThan < Struct.new(:left, :right)
  def reduce(environment)
    if left.reducible?
      reduced_left, environment = left.reduce(environment)
      [LessThan.new(reduced_left, right), environment]
    elsif right.reducible?
      reduced_right, environment = right.reduce(environment)
      [LessThan.new(left, reduced_right), environment]
    else
      [Boolean.new(left.value < right.value), environment]
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<<#{self}>>"
  end
end

class Number < Struct.new(:value)
  def reducible?
    false
  end

  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end
end

class Add < Struct.new(:left, :right)
  def reduce(environment)
    if left.reducible?
      reduced_left, environment = left.reduce(environment)
      [Add.new(reduced_left, right), environment]
    elsif right.reducible?
      reduced_right, environment = right.reduce(environment)
      [Add.new(left, reduced_right), environment]
    else
      [Number.new(left.value + right.value), environment]
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<<#{self}>>"
  end
end

class Multiply < Struct.new(:left, :right)
  def reduce(environment)
    if left.reducible?
      reduced_left, environment = left.reduce(environment)
      [Multiply.new(reduced_left, right), environment]
    elsif right.reducible?
      reduced_right, environment = right.reduce(environment)
      [Multiply.new(left, reduced_right), environment]
    else
      [Number.new(left.value * right.value), environment]
    end
  end

  def reducible?
    true
  end

  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end
end

