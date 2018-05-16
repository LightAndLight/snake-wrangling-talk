##

<style>
.reveal code { font-size: 0.8em; }
.reveal pre code { max-height: 600px; }
</style>


```haskell
append_to :: Statement
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

```python
def append_to (element, to=None):
    if to is None:
        to = []
    to.append(element)
    return to
```

##

```haskell
fixMutableDefaultArguments :: Statement -> Maybe Statement
```

<div class="notes">
You can write a function like this which pattern matches on a stateent and transforms it
if it contains mutable default arguments
</div>

##

```haskell
rewriteOn _Statements fixMutableDefaultArguments
  :: Module -> Module
```

<div class="notes">
And then use `rewrite` from Plated in lens to apply
</div>

