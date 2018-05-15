# Property Testing

##

Invaluable!

<div class="notes">
In property testing you assert that the output of a function should always have some
relation to the input, for all input values. You build a random generator, and the framework
will use that to generate many random values and check that the property holds
</div>

##

Property of `plus`:

`for all inputs A and B: A + B == B + A`

##

Parsing, printing, and validating Python source have useful properties

##

`print . parse = id`

<div class="notes">
For example, print dot parse equals id is a property that says "for all python programs,
printing the result of successfully parsing the input gives back the original program".

This is the round-trip property from earlier

Property testing is important to me because...
</div>

##

How do you know what you are really implementing Python?

<div class="notes">
Where this really comes in handy is answering this question.
</div>

##

`python3` is the final authority

<div class="notes">
So if I claim that a function will always produce valid python code, what better way to
check than by running it through the python interpreter?
</div>

##

1. Generate random Python program
2. Compile it with `python3` (running it could diverge!)
3. Assert something about the result (exit code, stdout, stderr)

##

You don't need to remember the whole language

<div class="notes">
The Python language reference is big and not awesomely written. There's edge cases hidden
away there.

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
  | Def Name [Parameter] [Statement]
  | While Expr [Statement]
  | ...

printStatement :: Statement -> String
printStatement = ...
  
genStatement :: MonadGen m => m Statement
genStatement = ...
```

<div class="notes">
You can build random generators with applicative combinators.

In Python you can only have a break statement inside a loop, and if one is found outside a
loop then that's a syntax error.

So if we have a generator which can generate any statement and wrote a property that said
"printing any
Statement produces syntactically correct Python code", then it would eventually fail
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
def a():
  def b():
    ...
    break
```

<div class="notes">
The generator knows how to shrink the input
</div>

##

```python
def a():
  ...
  break
```

<div class="notes">
And will keep shrinking and re-testing
</div>

##

```python
...
break
```

##

```python
break
```

<div class="notes">
Until it finds the "smallest" input that fails the test
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

So that's a little bit about some stuff that worked really well for me. Let's talk about some
things that didn't work well
</div>

