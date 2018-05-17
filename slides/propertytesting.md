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

You don't need to remember the whole language

<div class="notes">
The Python language reference is big and not awesomely written. There's edge cases hidden
away there.

You don't need to load the language reference into your brain while you write. You can write
your best approximation, run the test suite, and it will tell you where you screwed up
</div>

##

Random generation is great for poking programming languages

<div class="notes">
I've found a bunch of funny behaviours with this
</div>

##

```python
((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((
```

<div class="notes">
This one we call the 94-paren bug- the parser stack-overflows if you enter 94 or more open parens/braces/brackets

So that's a little bit about some stuff that worked really well for me. Let's talk about some
things that didn't work well
</div>

