# vain
An extremely simple, tiny and easy to use V library for writing lexers.

# Usage
Vain lets you create lexer objects which act on an input string and follow a pre-defined set of rules you create to match tokens.
On top of that, it allows you to process tokens on the spot (using callback functions) to convert them to a format you're more comfortable with.

Here's a usage example:
```v
input := "My 001% awesome string!"

mut lexer := vain.make_lexer(
    input,
    [   // vain will try each rule from top to bottom
        // so it is good practice to order them by token importance!
        // when you specify a rule, the first argument is the token identifier
        // which can be anything you want. it is good practice to make it SCREAMING_CASE
        vain.regex("WHITESPACE", "( |\t|\n|\r)+"), // any whitespace. \s does not currently work with V
        vain.regex_callback("NUMBER", "[0-9]+", fn (str string) string {
            return str.reverse() // here, we reverse any number token we match
        }),
        vain.regex("WORD", "[a-zA-Z]+"), // match any letter
        vain.literal("PERCENT", "%"), // %
        vain.literal("EXCLAMATION", "!")  // !
    ],
    fn (str string) {
        // this is the error callback - the function here is executed if the lexer
        // fails to understand a token. this can happen due to not enough rules,
        // or certain rules being invalid.
        println("error when tokenizing. remaining input: $str") 
    }
)

for {
    // lexer.next() will grab the next token and its id
    // once there are no tokens left, the lexer will return none
    id, token := lexer.next() or {
        break
    }

    println("($id: $token)")
}

// output:
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