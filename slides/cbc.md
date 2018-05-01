# Correctness by Construction
<div class="notes">
In the beginning we decided it was important to have the syntax tree be correct by
construction, meaning
</div>

##

If we can construct some data, then that data is correct (by some measure)

<div class="notes">
It's impossible for you to create a value that is "incorrect"
</div>

##

Syntactically correct by construction

<div class="notes">
Our standard of correctness was "syntactically correct" - in that if you create a syntax
tree value, print it and run it through python3, then you won't get a syntax error
</div>

##

Incorrect = type error

<div class="notes">
In Haskell, the ideal situation is that mistakes end up being type errors. In other words,
the type checker is checking the correctness of our code. Seems like a good idea.
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

Now Python actually has two grammars, this one- which the parser is based on, and a second
"abstract grammar" which refines the result of parsing. Error in both stages count as
syntax errors.
</div>

##

```
data Expr
  = Int Int
  | Bool Bool 
  | Var String
  | ...

data Statement
  = Assign Expr [Whitespace] {-# '=' #-} [Whitespace] Expr
  | ...
```

<div class="notes">
Since we wanted that roundtrip property, we based the AST on the concrete parser grammar.
And it would have looked something like this
</div>

##

```
Assign (Int 1) (Int 2)
```

<div class="notes">
However this isn't correct by construction. This is still a valid term.
</div>

##

```
{-# language GADTs, DataKinds, KindSignatures #-}
```

<div class="notes">
So if we put on our wizard hats
</div>

##

```
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

```
expr :: Parser (Expr ??)
```

<div class="notes">
But this infects other parts of the program
</div>

##

```
import Data.Singletons


expr :: Sing assignable -> Parser (Expr assignable)

-- or

expr :: Parser (Sigma Assignable Expr)
```

<div class="notes">
But this infects other parts of the program. To make the types in parsing you'd have to use
singletons
</div>

##

```
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

```
expr :: Parser ExprU
statement :: Parser StatementU
```

<div class="notes">
Parse to that
</div>

##

```
validateExpr :: Sing assignable -> ExprU -> Either SyntaxError (Expr assignable)
validateStatement :: Sing assignable -> StatementU -> Either SyntaxError Statement
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

```
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

```
NOT LPAREN condition RPAREN

not(condition)
```

##

```
NOT NOT LPAREN condition RPAREN

notnot(condition)
```

##

```
NOT SPACE NOT LPAREN condition RPAREN

not not(condition)
```

##

Spaces are only required between tokens when their concatenation would create another token

<div class="notes">
WAY TOO MUCH to encode with types 
</div>

##

```
data Expr :: type_stuff -> * where
  Not
    :: {-# not #-}
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

```
mkNot
  :: {-# not #-}
     [Whitespace]
  -> Expr type_stuff
  -> Either SyntaxError (Expr type_stuff)
```

<div class="notes">
If you're not going to catch errors at compile-time, then you have to catch them at runtime.
in this case, with smart constructors.
</div>
