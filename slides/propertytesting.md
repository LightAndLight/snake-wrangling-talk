# Property Testing

##

Invaluable!

##

`python3` is the final authority on the definition of Python

<div class="notes">
So if I claim that a function will always produce valid python code, what better way to
check than by running it through the python interpreter?
</div>

##

1. Generate random Python program
2. Compile it with `python3` (running it could diverge!)
3. Assert something about the result

##

You don't need to remember the whole language

<div class="notes">
You don't need to load the language reference into your brain while you write. You can write
your best approximation, run the test suite, and it will tell you where you screwed up
</div>

##

Shrinking can find minimal counter-examples

<div class="notes">
Shinking is the process of re-running a failing test on some "smaller" input, to find their
"smallest" input that causes a failure.

In hedgehog (my property testing library of choice), random generators have an idea of how to
shrink their outputs based on how they are constructed. So instead of getting a big error
message that says "the error is somewhere in there", hedgehog can shrink it down to something
more reasonable.
</div>

##

```haskell
data Statement
  = Break
  | Def Name [Parameter] Body
  | While Expr Body
  | ...

printStatement :: Statement -> String
printStatement = ...
  
genStatement :: MonadGen m => m Statement
genStatement =
  Gen.recursive Gen.choice
  [ pure Break
  , ...
  ]
  [ Def <$> genName <*> genParameters <*> genBody
  , While <$> genExpr <*> genBody
  , ...
  ]
```

<div class="notes">
In Python you can only have a break statement inside a loop, and if one is found outside a
loop then that's a syntax error.

So if I started off with some code like this and wrote a property that said "printing any
PythonStatement produces syntactically correct Python code", then it would eventually fail
because it would generate a tree with 'break' outside
</div>

##

```python
def a():
  def b():
    def c():
      ...
      break
```

<div class="notes">
But it might generate amidst a jumble of other information
</div>

##

```python
break
```

<div class="notes">
The generator combinators know build up a shrinking function, so when the test fails, it
repeatedly shrinks the input and re-runs the function, until it ends up with something
like that
</div>

##

Random testing is great for poking programming languages

<div class="notes">
I've found a bunch of funny behaviours with this
</div>

##

```python
[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[
```

<div class="notes">
This one we call the 94-paren bug- the parser stack-overflows if you enter 94 or more open parens/braces/brackets
</div>
