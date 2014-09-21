require 'rspec'

module FizzBuzz
  ZERO  = -> p { -> x { x } }
  ONE   = -> p { -> x { p[x] } }
  TWO   = -> p { -> x { p[p[x]] } }
  THREE = -> p { -> x { p[p[p[x]]] } }
  FIVE  = -> p { -> x { p[p[p[p[p[x]]]]] } }
  FIFTEEN = -> p { -> x { p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[x]]]]]]]]]]]]]]] } }
  HUNDRED = -> p { -> x {
    p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[
    p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[
    p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[
    p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[
    p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[ p[p[p[p[p[
         x
    ]]]]]]]]]]]]]]]]]]]]
    ]]]]]]]]]]]]]]]]]]]]
    ]]]]]]]]]]]]]]]]]]]]
    ]]]]]]]]]]]]]]]]]]]]
    ]]]]]]]]]]]]]]]]]]]]
  }}

  TRUE  = -> x { -> y { x } }
  FALSE = -> x { -> y { y } }
  IF = -> b { b } # reduced from IF = -> b { -> x { -> y { b[x][y] } } }
  IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }

  PAIR  = -> x { -> y { -> f { f[x][y] } } } # -> f { f[x][y] } after construction
  LEFT  = -> p { p[-> x { -> y { x } }] }
  RIGHT = -> p { p[-> x { -> y { y } }] }

  INCREMENT = -> n { -> p { -> x { p[ n[p][x] ] } } }
  SLIDE = -> p { PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]] }
  DECREMENT = -> n { LEFT[n[SLIDE][PAIR[ZERO][ZERO]]] }

  ADD      = -> m { -> n { n[INCREMENT][m] } }
  SUBTRACT = -> m { -> n { n[DECREMENT][m] } }
  MULTIPLY = -> m { -> n { n[ADD[m]][ZERO] } }
  POWER    = -> m { -> n { n[MULTIPLY[m]][ONE] } }

  IS_LESS_OR_EQUAL = -> m { -> n { IS_ZERO[SUBTRACT[m][n]] } }

  # Y = -> f { -> x { f[x[x]] }[-> x { f[x[x]] }] }
  Z = -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[-> y { x[x][y] }] }] }
  MOD =
    Z[-> f {-> m { -> n { # using Z combinator to make recursive call inlineable
      IF[IS_LESS_OR_EQUAL[n][m]][
        -> x { # defer evaluation to avoid infinite recursive call
          f[SUBTRACT[m][n]][n][x]
        }
      ][
        m
      ]
    }}}]

  EMPTY = PAIR[TRUE][TRUE]
  UNSHIFT = -> l { -> x {
    PAIR[FALSE][PAIR[x][l]]
  }}
  IS_EMPTY = LEFT
  FIRST = -> l { LEFT[RIGHT[l]] }
  REST = -> l { RIGHT[RIGHT[l]] }

  RANGE =
    Z[-> f {
      -> m { -> n {
        IF[IS_LESS_OR_EQUAL[m][n]][
          -> x {
            UNSHIFT[f[INCREMENT[m]][n]][m][x]
          }
        ][
          EMPTY
        ]
      }}
    }]
  FOLD =
    Z[ -> f {
      -> l { -> x { -> g {
        IF[IS_EMPTY[l]][
          x
        ][
          -> y {
            g[f[REST[l]][x][g]][FIRST[l]][y]
          }
        ]
      }}}
    }]
  MAP =
    -> k { -> f {
      FOLD[k][EMPTY][
        -> l { -> x { UNSHIFT[l][f[x]] } }
      ]
    }}

  TEN = MULTIPLY[TWO][FIVE]
  B = TEN
  F = INCREMENT[B]
  I = INCREMENT[F]
  U = INCREMENT[I]
  ZED = INCREMENT[U]

  FIZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F]
  BUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B]
  FIZZBUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F]

  DIV =
    Z[-> f { -> m { -> n {
      IF[IS_LESS_OR_EQUAL[n][m]][
        -> x {
          INCREMENT[f[SUBTRACT[m][n]][n]][x]
        }
      ][
        ZERO
      ]
    }}}]
  PUSH =
    -> l { -> x {
      FOLD[l][UNSHIFT[EMPTY][x]][UNSHIFT]
    }}
  TO_DIGITS =
    Z[-> f { -> n { PUSH[
      IF[IS_LESS_OR_EQUAL[n][DECREMENT[TEN]]][
        EMPTY
      ][
        -> x {
          f[DIV[n][TEN]][x]
        }
      ]
    ][MOD[n][TEN]]}}]


  describe 'FizzBuzz made from procs' do
    def to_char(c)
      '0123456789BFiuz'.slice(to_integer(c))
    end

    def to_string(s)
      to_array(s).map { |c| to_char(c) }.join
    end

    def to_array(proc)
      array = []
      until to_boolean(IS_EMPTY[proc])
        array.push(FIRST[proc])
        proc = REST[proc]
      end
      array
    end

    def to_int_array(proc)
      to_array(proc).map{ |it| to_integer(it) }
    end

    def to_boolean(proc)
      IF[proc][true][false]
    end

    def to_integer(proc)
      proc[-> n { n + 1 }][0]
    end

    it 'solves FizzBuzz problem' do
      # using 1..20 range because TO_DIGITS is very slow
      solution =
          MAP[RANGE[ONE][MULTIPLY[TEN][TWO]]][ -> n {
            IF[IS_ZERO[MOD[n][FIFTEEN]]][
              FIZZBUZZ
            ][IF[IS_ZERO[MOD[n][THREE]]][
              FIZZ
            ][IF[IS_ZERO[MOD[n][FIVE]]][
              BUZZ
            ][
              TO_DIGITS[n]
            ]]]
          }]
      result = to_array(solution).map { |p| to_string(p) }
      expect(result).to eq(%w(
        1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz
        11 Fizz 13 14 FizzBuzz 16 17 Fizz 19 Buzz
      ))
    end

    it 'can convert numbers to strings' do
      expect(to_string(TO_DIGITS[FIVE])).to eq('5')
      expect(to_string(TO_DIGITS[FIFTEEN])).to eq('15')
      # expect(to_string(TO_DIGITS[POWER[FIVE][THREE]])).to eq('125') # slow
    end

    it 'has strings' do
      expect(to_char(F)).to eq('F')
      expect(to_char(ZED)).to eq('z')
      expect(to_string(FIZZBUZZ)).to eq('FizzBuzz')
    end

    it 'has map operator' do
      expect(to_int_array(MAP[RANGE[ONE][FIVE]][INCREMENT])).to eq([2, 3, 4, 5, 6])
    end

    it 'has fold operator' do
      expect(to_integer(FOLD[RANGE[ONE][FIVE]][ZERO][ADD])).to eq(15)
      expect(to_integer(FOLD[RANGE[ONE][FIVE]][ONE][MULTIPLY])).to eq(120)
    end

    it 'has ranges' do
      expect(to_int_array(RANGE[ONE][FIVE])).to eq([1, 2, 3, 4, 5])
    end

    it 'has lists' do
      expect(to_int_array(UNSHIFT[EMPTY][ONE])).to eq([1])
      expect(to_int_array(UNSHIFT[UNSHIFT[EMPTY][ONE]][TWO])).to eq([2, 1])
      expect(to_int_array(UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ONE]][TWO]][THREE])).to eq([3, 2, 1])

      list = UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ONE]][TWO]][THREE]
      expect(to_integer(FIRST[list])).to eq(3)
      expect(to_int_array(REST[list])).to eq([2, 1])
      expect(to_boolean(IS_EMPTY[EMPTY])).to be(true)
      expect(to_boolean(IS_EMPTY[list])).to be(false)
    end

    it 'has mod operator' do
      expect(to_integer(MOD[THREE][TWO])).to eq(1)
      expect(to_integer(MOD[POWER[THREE][THREE]][ADD[THREE][TWO]])).to eq(2)
    end

    it 'has less or equal operator' do
      expect(to_boolean(IS_LESS_OR_EQUAL[ONE][TWO])).to be(true)
      expect(to_boolean(IS_LESS_OR_EQUAL[TWO][TWO])).to be(true)
      expect(to_boolean(IS_LESS_OR_EQUAL[THREE][TWO])).to be(false)
    end

    it 'has arithmetic operations' do
      expect(to_integer(ADD[ZERO][ZERO])).to eq(0)
      expect(to_integer(ADD[ZERO][ONE])).to eq(1)
      expect(to_integer(ADD[ONE][ZERO])).to eq(1)
      expect(to_integer(ADD[ONE][ONE])).to eq(2)
      expect(to_integer(ADD[HUNDRED][FIFTEEN])).to eq(115)

      expect(to_integer(SUBTRACT[ZERO][ZERO])).to eq(0)
      expect(to_integer(SUBTRACT[ZERO][ONE])).to eq(0) # not -1
      expect(to_integer(SUBTRACT[ONE][ZERO])).to eq(1)
      expect(to_integer(SUBTRACT[ONE][ONE])).to eq(0)
      expect(to_integer(SUBTRACT[HUNDRED][FIFTEEN])).to eq(85)

      expect(to_integer(MULTIPLY[ZERO][ZERO])).to eq(0)
      expect(to_integer(MULTIPLY[ONE][ONE])).to eq(1)
      expect(to_integer(MULTIPLY[HUNDRED][FIFTEEN])).to eq(1500)

      expect(to_integer(POWER[ZERO][ZERO])).to eq(1) # yes, this is "correct"
      expect(to_integer(POWER[ZERO][ONE])).to eq(0)
      expect(to_integer(POWER[ZERO][TWO])).to eq(0)
      expect(to_integer(POWER[ONE][ZERO])).to eq(1)
      expect(to_integer(POWER[ONE][ONE])).to eq(1)
      expect(to_integer(POWER[ONE][TWO])).to eq(1)
      expect(to_integer(POWER[TWO][THREE])).to eq(8)
    end

    it 'can increment/decrement numbers' do
      expect(to_integer(INCREMENT[ZERO])).to eq(1)
      expect(to_integer(INCREMENT[ONE])).to eq(2)
      expect(to_integer(INCREMENT[HUNDRED])).to eq(101)

      expect(to_integer(DECREMENT[ZERO])).to eq(0) # not -1
      expect(to_integer(DECREMENT[ONE])).to eq(0)
      expect(to_integer(DECREMENT[HUNDRED])).to eq(99)
    end

    it 'has pairs' do
      pair = PAIR[THREE][FIVE]
      expect(to_integer(LEFT[pair])).to eq(3)
      expect(to_integer(RIGHT[pair])).to eq(5)
    end

    it 'has booleans' do
      expect(to_boolean(TRUE)).to be(true)
      expect(to_boolean(FALSE)).to be(false)

      expect(IF[TRUE]['happy']['sad']).to eq('happy')
      expect(IF[FALSE]['happy']['sad']).to eq('sad')

      expect(to_boolean(IS_ZERO[ZERO])).to be(true)
      expect(to_boolean(IS_ZERO[ONE])).to be(false)
    end

    it 'has numbers' do
      expect(to_integer(ZERO)).to eq(0)
      expect(to_integer(ONE)).to eq(1)
      expect(to_integer(THREE)).to eq(3)
      expect(to_integer(FIVE)).to eq(5)
      expect(to_integer(FIFTEEN)).to eq(15)
      expect(to_integer(HUNDRED)).to eq(100)
    end
  end
end

