# Correctness by Construction

##

If we can construct some data, then that data is correct (by some measure)

<div class="notes">
In the beginning we decided it was important to have the syntax tree be correct by
construction, meaning

It's impossible for you to create a value that is "incorrect"
</div>

##

Incorrect = type error

<div class="notes">
In Haskell, the ideal situation is that mistakes end up being type errors. In other words,
the type checker is checking the correctness of our code. Seems like a good idea.
</div>

##

Syntactically correct by construction

<div class="notes">
Our standard of correctness was "syntactically correct" - in that if you create a syntax
tree value, print it and run it through python3, then you won't get a syntax error
</div>

##

Python syntax isn't very straightforward

<div class="notes">
In domains that follow a consistent, logical design, leaning on the type system for things
like this is a boon. But there are so many gotchas in the Python syntax, and fixing each
one with type invariants made the library more and more complex.

Python has 3 levels of "grammar" or "syntax". The first level is the "concrete" grammar - the one
the parser implements. The second level is the "actual" grammar, which corrects a bunch often
things that they didn't encode in the concrete grammar. The third tier is some edge cases on top
of that.
</div>

##

```haskell
data Expr
  = Int Int
  | Bool Bool 
  | Var String
  | ...

data Statement
  = Assign Expr Expr
  | ...
```

<div class="notes">
Since we wanted that roundtrip property, we based the AST on the concrete parser grammar.
And it would have looked something like this
</div>

##

```haskell
Assign (Int 1) (Int 2)
```

```python
1 = 2
```

<div class="notes">
There are certain things you can't assign to, including literals. And if you try then you
get a syntax error in the python repl
</div>

##

```haskell
data Expr
  = Int Int
  | Bool Bool 
  | Var String
  | ...

data AssignableExpr
  = AEVar String
  | ...

data Statement
  = Assign AssignableExpr Expr
  | ...
```

<div class="notes">
You could make a data type for terms which can be assigned to, but assignable expressions are
a strict subset of expressions, so that would just be duplicating code that really means the
same thing
</div>

##

```haskell
{-# language GADTs, DataKinds, KindSignatures #-}
```

<div class="notes">
So if we put on our wizard hats
</div>

##

```haskell
data Assignable = IsAssignable | NotAssignable

data Expr :: Assignable -> * where
  Int :: Int -> Expr 'NotAssignable
  Bool :: Bool -> Expr 'NotAssignable
  Var :: String -> Expr a
  ...

data Statement
  = Assign (Expr 'IsAssignable) (Expr 'NotAssignable)
  | ...
```

<div class="notes">
We can zap the problem away
</div>

##

```haskell
expr :: Parser (Expr ??)
```

<div class="notes">
But this infects other parts of the program
</div>

##

```haskell
exprAssignable :: Parser (Expr 'Assignable)
exprNotAssignable :: Parser (Expr 'NotAssignable)
```

<div class="notes">
You could split up the parser so that you can pick which sort of expression you're
trying to parse

But this will get you weird errors because the parser now describes an ambiguous
grammar
</div>

##

```haskell
data ExprU
  = IntU Int
  | BoolU Bool 
  | VarU String
  | ...

data StatementU
  = AssignU ExprU ExprU
  | ...
```

<div class="notes">
It's better to create a dumb, unvalidated data structure
</div>

##

```haskell
expr :: Parser ExprU
statement :: Parser StatementU
```

<div class="notes">
Parse to that
</div>

##

```haskell
validateExprAssignable
  :: ExprU
  -> Either SyntaxError (Expr 'Assignable)

validateExprNotAssignable
  :: ExprU
  -> Either SyntaxError (Expr 'NotAssignable)

validateStatement
  :: StatementU
  -> Either SyntaxError Statement
```

<div class="notes">
And then validate it in a way that builds the correct-by-construction one.

This is what I chose to do, but it's still unsatisfying because there is a lot of code
duplication. Validated terms are a subset of unvalidated terms.
</div>

##

Rinse and repeat

<div class="notes">
I think datakinds and gadts are really cool for getting quick compiler-checked wins, but it
becomes more unwieldy the more conditions you need to encode.

The real syntax tree was much bigger so the changes propagated across a lot more code.
</div>

##

But it (mostly) worked... until...

<div class="notes">
But it "worked". I could round-trip thousand-line files from github. It was just a bit of
a behemoth.
</div>

##

`not(condition)`

<div class="notes">
Until I was got by some code like this in a real-world file.

Everything fell apart
</div>

##

```haskell
data Expr :: type_stuff -> * where
  Not
    :: {- not -}
       NonEmpty Whitespace
    -> Expr type_stuff
    -> Expr type_stuff 
  Parens
    :: Expr type_stuff
    -> Expr type_stuff 
  ...
```

<div class="notes">
Up until now, I had been requiring 1 or more spaces after keywords, but this in incorrect.
Spaces are only required between tokens when their concatenation would be a single token
</div>

##

```haskell
NonEmpty Whitespace -> [Whitespace]
```

##

```haskell
data Expr :: type_stuff -> * where
  Not
    :: {- not -}
       [Whitespace]
    -> Expr type_stuff
    -> Expr type_stuff 
  Parens
    :: Expr type_stuff
    -> Expr type_stuff 
  ...
```

##

```haskell
Not [] (Parens condition)
```

`not(condition)`

##

```haskell
Not [] (Not [] (Parens condition))
```

`notnot(condition)`

<div class="notes">
But now that's a function call, not logical negation, because "notnot" is an identifier
</div>

##

Spaces are only required between tokens when their concatenation would give a single token

<div class="notes">
WAY TOO MUCH to encode with types 

I had brainstormed some ways to get it working, but it seemed like way too much effort,
and it would be too complex for the benefit we would get
</div>

##

```haskell
mkNot
  :: {- not -}
     [Whitespace]
  -> Expr type_stuff
  -> Either SyntaxError (Expr type_stuff)
```

<div class="notes">
We have to revert to runtime checking with smart constructors, so we lose the game of
incorrect = type errors
</div>

##

```haskell
_Not :: Prism' Expr ([Whitespace], Expr)
```

<div class="notes">
And I also realised that smart constructors aren't compatible with traversals and prisms in
general

This prism would allow you to break the whitespace rules
</div>

##

```haskell
_Not :: Prism Expr ExprU ([Whitespace], Expr) ([Whitespace], ExprU)
```

<div class="notes">
This would be more accurate - it says that you can destructure an Expr into whitespace and
and expr, and you can construct an ExprU from whitespace and an ExprU, so you'd be forced
to re-validate the result of constructing something with the prism
</div>

##

```haskell
Expr -> ExprU
```

<div class="notes">
And a third problem- if you go with the 'unvalidating prism' style, you will need a function
that takes expressions to their unvalidated form. And in the current conception of the library
you would need to traverse the Expr and rebuild the equivalent ExprU.

But as I said before, I think Expr is a subset of ExprU, so that operation shouldn't cost
anything
</div>

##

It's all a bit too much

<div class="notes">
I made the library more complicated to get compiler-checked guarantees, and I couldn't even
get that for the whole domain. I think it would only have value if it were all compiler
checked.

Now it's just inconsistently designed.
</div>

