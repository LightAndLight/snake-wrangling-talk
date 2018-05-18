# The Drawing Board

##

~~Correct by Construction~~

<div class="notes">
Since I had already conceded some of the validation to runtime, I decided
to leave all validation to runtime
</div>

##

~~Concrete Syntax Tree~~

##

~~Validated/Unvalidated Trees~~

##

```haskell
data Expr (ts :: [*])
  = Int Int
  | Bool Bool
  | Var String
  | Not (Expr ts)
  | ...

data Statement (ts :: [*])
  = Assign (Expr ts) (Expr ts)
  | ...
```

<div class="notes">
Simple data structures that represents the python code, not the syntax

It is still decorated with whitespace and such needed for formatting, but that's ignorable

We still want some way to differentiate between syntactically correct and
unvalidated trees on the type level, which we can do using the type level
list
</div>

##

```haskell
-- raw, unvalidated
Expr '[]

-- syntax validated
Expr '[Syntax]

-- indentation & syntax validated
Statement '[Indentation, Syntax]
```

<div class="notes">
An empty list means "unvalidated", and extending it represents another "level"
of validation
</div>

##

```haskell
data Indentation

validateStatementIndentation
  :: Statement ts
  -> Either SyntaxError (Statement (Nub (Indentation ': ts)))
```

<div class="notes">
By treating that type level list as a set, validation becomes idempotent
</div>

##

```haskell
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

```haskell
_Not
  :: Prism
       (Expr ts)
       (Expr '[])
       ([Whitespace], Expr ts)
       ([Whitespace], Expr '[])
```

<div class="notes">
This makes it really easy to write prisms which never lie
</div>

##

```haskell
import Data.Coerce

unvalidateStatement :: Statement ts -> Statement '[]
unvalidateStatement = coerce
```

<div class="notes">
It also means that "unvalidation" is free, because the type-level validation list is a
phantom type, so you can coerce it away
</div>

##

Making 'incorrect' things impossible

vs.

Making 'correct' things trivial

<div class="notes">
I think there is a point in Haskell development where this can become a dichotomy,
and when confronted which a choice, I choose the latter

If we make it very easy to check whether a syntax tree is correct, and provide helpful
error messages, then it's inconsequential that we can construct incorrect trees.

There are still easy wins for correct-by-construction, like using non-empty lists.
Very simple things that don't impact on usability.

This is why I'm okay with the use of coerce. Coercing is an implementation detail,
and you actually have to go out of your way to use it. If we design a high-level API that
is easy to use and always correct, then users will never consider subverting it.
</div>

##

Modelling how things appear

vs.

Modelling what things mean

<div class="notes">
In other words, the dichotomy between concrete and abstract.

Your API has a good user experience when it lines up with the user's conceptual model. And
I think that's what happens when we shift from concrete syntax to abstract syntax. People's
mental model of python is not the syntax, it's the concepts behind the syntax, so people
can more easily draw upon their existing knowledge to use the library.
</div>

