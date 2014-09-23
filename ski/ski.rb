class SKISymbol < Struct.new(:name)
  def as_a_function_of(name)
    if self.name == name
      I
    else
      SKICall.new(K, self)
    end
  end

  def reducible?
    false
  end

  def callable?(*arguments)
    false
  end

  def combinator
    self
  end

  def arguments
    []
  end

  def to_s
    name.to_s
  end

  def inspect
    to_s
  end
end

class SKICall < Struct.new(:left, :right)
  def as_a_function_of(name)
    left_function = left.as_a_function_of(name)
    right_function = right.as_a_function_of(name)
    SKICall.new(SKICall.new(S, left_function), right_function)
  end

  def reducible?
    left.reducible? or right.reducible? or combinator.callable?(*arguments)
  end

  def reduce
    if left.reducible?
      SKICall.new(left.reduce, right)
    elsif right.reducible?
      SKICall.new(left, right.reduce)
    else
      combinator.call(*arguments)
    end
  end

  def combinator
    left.combinator
  end

  def arguments
    left.arguments + [right]
  end

  def to_s
    "#{left}[#{right}]"
  end

  def inspect
    to_s
  end
end

class SKICombinator < SKISymbol
  def as_a_function_of(name)
    SKICall.new(K, self)
  end

  def callable?(*arguments)
    arguments.length == method(:call).arity
  end
end

S, K, I = [:S, :K, :I].map { |name| SKICombinator.new(name) }

# reduce S[a][b][c] to a[c][b[c]]
def S.call(a, b, c)
  SKICall.new(SKICall.new(a, c), SKICall.new(b, c))
end

# reduce K[a][b] to a
def K.call(a, b)
  a
end

# reduce I[a]
def I.call(a)
  a
end

def reduce(expression)
  steps = []
  while expression.reducible?
    steps.push(expression)
    expression = expression.reduce
  end
  steps.push(expression)
  steps
end