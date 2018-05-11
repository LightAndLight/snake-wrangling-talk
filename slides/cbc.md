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
</div>

##

`1 = 2`

<div class="notes">
Consider this assignment statement. This is considered a syntax error.

"Can't assign to a literal"
</div>

##

`assign_stmt ::= expr '=' expr`

<div class="notes">
The Python grammar says something to this effect: that both sides of the equals should be
parsed as expressions.

Now Python actually has two and a half grammars, this one- which the parser is based on,
a second "abstract grammar" which refines the result of parsing, and a third "syntax check"
phase which has extra syntactic constraints. Error in both stages count as syntax errors.
</div>

##

```haskell
data Expr
  = Int Int
  | Bool Bool 
  | Var String
  | ...

data Statement
  = Assign Expr [Whitespace] {- '=' -} [Whitespace] Expr
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

<div class="notes">
However this isn't correct by construction. This is still a valid term.
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
  = Assign
      (Expr 'IsAssignable)
      [Whitespace] {-# '=' #-} [Whitespace]
      (Expr 'NotAssignable)
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
import Data.Singletons


expr :: Sing assignable -> Parser (Expr assignable)

-- or

expr :: Parser (Sigma Assignable Expr)
```

<div class="notes">
But this infects other parts of the program. To make the types in parsing you'd have to use
singletons, or alternatively you can parse to an unvalidated tree, and then validate that
to build the type-safe version
</div>

##

```haskell
data ExprU
  = IntU Int
  | BoolU Bool 
  | VarU String
  | ...

data StatementU
  = AssignU ExprU [Whitespace] {-# '=' #-} [Whitespace] ExprU
  | ...
```

<div class="notes">
Or for better error messages, you create an unvalidate datatype that mirrors the syntax
tree
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
validateExpr
  :: Sing assignable
  -> ExprU
  -> Either SyntaxError (Expr assignable)

validateStatement
  :: Sing assignable
  -> StatementU
  -> Either SyntaxError Statement
```

<div class="notes">
And then validate *that* in a way that builds the correct-by-construction one.
</div>

##

Rinse and repeat

<div class="notes">
It doesn't seem like a big deal in this instance, but there were more gotchas, some less
intuitive than this one, and the real syntax tree was much bigger so the changes propagated
across a lot more code.
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
    :: {-# not #-}
       NonEmpty Whitespace
    -> Expr type_stuff
    -> Expr type_stuff 
  ...
```

<div class="notes">
Up until now, I had been requiring 1 or more spaces after keywords, but this in incorrect.
Spaces are only required between tokens when their concatenation would create another token
</div>

##

`not(condition)`

<div class="notes">
You can't fit this expression into that data structure
</div>

##

`NOT LPAREN condition RPAREN`

`not(condition)`

<div class="notes">
There's a mismatch here because Python implementations use a lexer, which transforms the source
into a sequence of tokens before parsing
</div>

##

`NOT NOT LPAREN condition RPAREN`

`notnot(condition)`

<div class="notes">
If we had two adjacent "not" tokens, they would actually be an identifier token
</div>

##

`IDENT(notnot) LPAREN condition RPAREN`

`notnot(condition)`

##

`NOT SPACE NOT LPAREN condition RPAREN`

`not not(condition)`

<div class="notes">
So they need to be separated by a space to be distinct
</div>

##

Spaces are only required between tokens when their concatenation would create another token

<div class="notes">
WAY TOO MUCH to encode with types 

I had brainstormed some ways to get it working, but it seemed like way too much effort for
the benefit we would get
</div>

##

```haskell
data Expr :: type_stuff -> * where
  Not
    :: {- not -}
       [Whitespace]
    -> Expr type_stuff
    -> Expr type_stuff 
  ...
```

<div class="notes">
If you're not going to catch errors at compile-time, then you have to catch them at runtime.
in this case, with smart constructors.
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
If you're not going to catch errors at compile-time, then you have to catch them at runtime.
in this case, with smart constructors.

But this isn't compatible with lenses!
</div>

##

```haskell
_Not :: Prism' Expr ([Whitespace], Expr)
```

<div class="notes">
Another important consideration is how this things interact with lenses.

This prism would allow you to break the whitespace rules
</div>

##

```haskell
_Not :: Prism Expr ExprU ([Whitespace], ExprU) ([Whitespace], Expr)
```

<div class="notes">
This would be more accurate - it says that you can destructure an Expr into whitespace and
and expr, and you can construct an ExprUnchecked from whitespace and an ExprUnchecked
</div>

##

It's all a bit too much

<div class="notes">
By this stage I had made too many concessions to get to this idea of
"correct-by-construction", and started to question what I was getting in return. I wasn't
satisfied, so I started thinking about better designs.
</div>