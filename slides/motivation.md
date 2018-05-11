# Motivation

##

<style>
.reveal code { font-size: 0.8em; }
.reveal pre code { max-height: 600px; }
</style>

"Haskell's great, but..."

##

"...we can't afford to rewrite our entire product."

##

"So we're stuck with `LANG` for now."

<div class="notes">
Even if people are convinced of the value of a language, it's often too costly
to actually use it on the job.
</div>

##

How can we bring the benefits of better languages to existing codebases?

<div class="notes">
One of the things we're interested in at QFPL is how we can lower that barrier
</div>

##

Language tooling

<div class="notes">
My attempt at an answer is through language tooling
</div>

##

Language tooling for Python

<div class="notes">
I was doing pure Python at my old job, and many people in data61 use python, so
we decided on that as our first target.

Actually, I think it was a toss up between Javascript and Python so Tony and I played a
game of table tennis, and Tony won, so we did Python.
</div>

##

`hpython`

<div class="notes">
For lack of a better name, that project has been known as "hpython"
</div>

