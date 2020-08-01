# vain
An extremely simple, tiny and easy to use V library for writing lexers.

# Usage
Vain lets you create lexer objects which act on an input string and follow a pre-defined set of rules you create to match tokens.
On top of that, it allows you to process tokens on the spot (using callback functions) to convert them to a format you're more comfortable with.

Here's a [usage example](vain_test.v) , which outputs:
```
// (WORD: My)
// (WHITESPACE: )
// (NUMBER: 100)
// (PERCENT: %)
// (WHITESPACE：)
// (WORD：awesome)
// (WHITESPACE: )
// (WORD: string)
// (EXCLAMATION: !)
```
