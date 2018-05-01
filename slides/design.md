# Design

##

Parse & Print

<div class="notes">
To begin with, all language tools need to parse and print
</div >

##

`print . parse = id`

<div class="notes">
We also decided that it was important to have a round-trip property - that printing the
result of parsing some Python gives back the same source code - so we don't reformat code
</div >

##

Write & Check 

<div class="notes">
We also want to be able to write and modify Python programs using Haskell. And in some way,
we need to have assurance that the Python we are writing is not gibberish.
</div >
