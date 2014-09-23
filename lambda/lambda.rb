require_relative '../ski/ski'

def lc_reduce(expression)
  steps = []
  while expression.reducible?
    steps.push(expression)
    expression = expression.reduce
  end
  steps.push(expression)
  steps
end

class LCCall < Struct.new(:left, :right)
  def to_ski
    SKICall.new(left.to_ski, right.to_ski)
  end

  def reduce
    if left.reducible?
      LCCall.new(left.reduce, right)
    elsif right.reducible?
      LCCall.new(left, right.reduce)
    else
      left.call(right)
    end
  end

  def reducible?
    left.reducible? or right.reducible? or left.callable?
  end

  def replace(name, replacement)
    LCCall.new(left.replace(name, replacement), right.replace(name, replacement))
  end

  def callable?
    false
  end

  def to_s
    "#{left}[#{right}]"
  end

  def inspect
    to_s
  end
end

class LCFunction < Struct.new(:parameter, :body)
  def to_ski
    body.to_ski.as_a_function_of(parameter)
  end

  def call(argument)
    body.replace(parameter, argument)
  end

  def reducible?
    false
  end

  def callable?
    true
  end

  def replace(name, replacement)
    if parameter == name
      self
    else
      LCFunction.new(parameter, body.replace(name, replacement))
    end
  end

  def to_s
    "-> #{parameter} { #{body} }"
  end

  def inspect
    to_s
  end
end

class LCVariable < Struct.new(:name)
  def to_ski
    SKISymbol.new(name)
  end

  def replace(name, replacement)
    if self.name == name
      replacement
    else
      self
    end
  end

  def reducible?
    false
  end

  def callable?
    false
  end

  def to_s
    name.to_s
  end

  def inspect
    to_s
  end
end