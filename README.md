`hpython` is a Haskell library implementing a parser, printer, and
syntax tree for Python, written to allow easy validation and refactoring of complete Python programs.

As examples, we will look at functions which:

* Replace tabs with spaces
* Fix mutable default arguments, and
* Turn tail recursion into loops

These functions can also be composed, so a user can mix and match refactor-functions,
or write their own.

The library wasn't always like this, though. We've had ups and downs, and actually ended
up throwing out the entire previous design, which was months old at that point. I'm going
to share this journey: how the project goals evolved, failures and successes, and the lessons
I learned along the way. Key points include:

* The real-world value of property testing
* The shortcomings of advanced type-level techniques and compiler-enforced correctness
* The difference between "making it difficult to do the wrong thing" vs. "making it easy to do the right thing"
