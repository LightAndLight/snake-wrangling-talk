# Now

##

```haskell
append_to :: Statement '[]
append_to =
  def_ "append_to" [ p_ "element", k_ "to" (list_ []) ]
    [ expr_ $ call_ ("to" /> "append") [ "element" ]
    , return_ "to"
    ]
```

<div class="notes">
You can write python programs in Haskell
</div>

##

```python
def append_to (element, to=[]):
    to.append(element)
    return to
```

<div class="notes">
It renders as this
</div>

##

```haskell
fixMutableDefaultArguments :: Statement '[] -> Maybe (Statement '[])
```

<div class="notes">
You can write a function like this which pattern matches on a stateent and transforms it
if it contains mutable default arguments
</div>

##

```haskell
rewrite fixMutableDefaultArguments append_to
  :: Statement '[] -> Statement '[]
```

<div class="notes">
And then use `rewrite` from Plated in lens to apply
</div>

##

```python
def append_to(element, to=None):
    if to is None:
        to = []
    to.append(element)
    return to
```

<div class="notes">
It'll transform it to something that looks like this
</div>

##

```haskell
fact_tr :: Statement '[]
fact_tr =
  def_ "fact" [p_ "n"]
  [ def_ "go" [p_ "n", p_ "acc"]
    [ ifElse_ ("n" .== 0)
      [return_ "acc"]
      [return_ $ call_ "go" [p_ $ "n" .- 1, p_ $ "n" .* "acc"]]
    ]
  , return_ $ call_ "go" [p_ "n", p_ 1]
  ]
```

##

```python
def fact(n):
    def go(n, acc):
        if n == 0:
            return acc
        else:
            return go(n - 1, n * acc)
    return go(n, 1)
```

##

```haskell
optimizeTailRecursion :: Statement '[] -> Maybe (Statement '[])
```

##

```haskell
rewrite optimizeTailRecursion fact_r :: Statement '[] -> Statement '[]
```

##

```python
def fact(n):
    def go(n, acc):
        n__tr = n
        acc__tr = acc
        __res__tr = None
        while True:
            if n__tr == 0:
                __res__tr = acc__tr
                break
            else:
                n__tr__old = n__tr
                acc__tr__old = acc__tr
                n__tr = n__tr__old - 1
                acc__tr = n__tr__old * acc__tr__old
        return __res__tr
    return go(n, 1)
```

