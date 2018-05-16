# Cool Stuff

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

