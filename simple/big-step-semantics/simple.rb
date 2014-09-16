require_relative '../small-step-semantics/simple'

class While
  def evaluate(environment)
    case condition.evaluate(environment)
      when Boolean.new(true)
        evaluate(body.evaluate(environment))
      when Boolean.new(false)
        environment
      else
        raise("Unsupported condition: #{condition}")
    end
  end
end

class Sequence
  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end

class Assign
  def evaluate(environment)
    environment.merge({name => expression.evaluate(environment)})
  end
end

class DoNothing
  def evaluate(environment)
    environment
  end
end

class If
  def evaluate(environment)
    case condition.evaluate(environment)
      when Boolean.new(true)
        consequence.evaluate(environment)
      when Boolean.new(false)
        alternative.evaluate(environment)
      else
        raise("Unsupported condition: #{condition}")
    end
  end
end

class Number
  def evaluate(environment)
    self
  end
end

class Boolean
  def evaluate(environment)
    self
  end
end

class Variable
  def evaluate(environment)
    environment[name]
  end
end

class Add
  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end
end

class Multiply
  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end
end

class LessThan
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end
end


