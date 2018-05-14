# Concrete Syntax Tree

##

Have the data structures mirror the syntax

<div class="notes">
Because we decided to preserve formatting, I thought the best starting point for
a data structure would be one that matches the grammar
</div>

##

<img src="./img/pythongrammar.png" height="600px"></img>

<div class="notes">
Here's part of the grammar. You don't have to be able to read it, there's
just a lot of stuff there. And I was turning this into a bunch of equivalent
data structures.
</div>

##

`AST.hs` had way too many lines of code

<div class="notes">
There was way too much code. The amount of changes I had to make when I wanted
to add something new to the types was setting off alarm bells.

And I consider it a mistake
</div>

##

Syntax is not code

<div class="notes">
The grammar only exists because we read and write code using free-form text
Code is more abstract, it's meaning which the syntax conveys. The grammar is
often more complicated to appease parser generators

This library is about python code, not just the syntax. So I think the core
of the library should represent the abstract code, rather than the concrete
syntax.
</div>

