#

The Drawing Board

##

~~Correct by Construction~~

<div class="notes">
Since I had already conceded some of the validation to runtime, I decided
to leave all validation to runtime
</div>

##

```
data Expr (ts :: [*])
  = Int Int
  | Bool Bool
  | Var String
  | Not (Expr ts)
  | ...

data Statement (ts :: [*])
  = Assign (Expr ts) [Whitespace] {- '=' -} [Whitespace] (Expr ts)
  | ...
```

<div class="notes">
A single syntax tree

We still want some way to differentiate between syntactically correct and
unvalidated trees on the type level, which we can do using the type level
list
</div>

##

```
Expr '[]
Expr '[Syntax]
Statement '[Indentation, Syntax]
Statement '[Indentation, Syntax, Scope]
```

<div class="notes">
An empty list means "unvalidated", and extending it represents another "level"
of validation
</div>

##

```
data Indentation

validateStatementIndentation
  :: Statement ts
  -> Either SyntaxError (Statement (Nub (Indentation ': ts)))
```

<div class="notes">
By treating that type level list as a set, validation becomes idempotent
</div>

##

```
data Syntax

validateStatementSyntax
  :: Member Indentation ts
  => Statement ts
  -> Either SyntaxError (Statement (Nub (Syntax ': ts)))
```

<div class="notes">
You can also express preconditions by asserting that the set contains a
particular element
</div>

##

```
_Not :: Prism' (Expr ts) (Expr '[])_([Whitespace], Expr ts) ([Whitespace], Expr '[])
```

<div class="notes">
This makes it really easy to write prisms which never lie
</div>

##

```
import Data.Coerce

unvalidateStatement :: Statement ts -> Statement '[]
unvalidateStatement = coerce
```

<div class="notes">
It also means that "unvalidation" is free, because it only happens at the
type level
</div>

##

How is it safe if you can just `coerce` everything?
