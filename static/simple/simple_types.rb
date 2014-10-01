require_relative '../../simple/small-step-semantics/simple'
require_relative '../../simple/big-step-semantics/simple'

class Type < Struct.new(:name)
  NUMBER, BOOLEAN, VOID = [:number, :boolean, :void].map{ |name| new(name) }

  def inspect
    "#<Type #{name}>"
  end
end

class Number
  def type(context)
    Type::NUMBER
  end
end

class Boolean
  def type(context)
    Type::BOOLEAN
  end
end

class Add
  def type(context)
    if left.type(context) == Type::NUMBER and right.type(context) == Type::NUMBER
      Type::NUMBER
    end
  end
end

class LessThan
  def type(context)
    if left.type(context) == Type::NUMBER and right.type(context) == Type::NUMBER
      Type::BOOLEAN
    end
  end
end

class Variable
  def type(context)
    context[name]
  end
end

class DoNothing
  def type(context)
    Type::VOID
  end
end

class Sequence
  def type(context)
    if first.type(context) == Type::VOID && second.type(context) == Type::VOID
      Type::VOID
    end
  end
end

class If
  def type(context)
    if condition.type(context) == Type::BOOLEAN and
        consequence.type(context) == Type::VOID and
        alternative.type(context) == Type::VOID
      Type::VOID
    end
  end
end

class While
  def type(context)
    if condition.type(context) == Type::BOOLEAN and body.type(context) == Type::VOID
      Type::VOID
    end
  end
end

class Assign
  def type(context)
    if context[name] == expression.type(context)
      Type::VOID
    end
  end
end