# vain
An extremely simple, easy to use V library for writing lexers.
Currently WIP, but close to completion.

# Usage
Vain lets you create lexer objects which act on an input string and follow a pre-defined set of rules you create to match tokens. On top of that, it allows you to process tokens on the spot to convert them to a format you're more comfortable with.

```v
input := "My 001% awesome string!"

mut lexer := vain.make_lexer(
    input,
    [   // vain will try each rule from top to bottom
        // so it is good practice to order them by token importance!
        vain.regex("( |\t|\n|\r)+"), // any whitespace. can also use \s+ instead
        vain.regex_callback("[0-9]+", fn (str string) string {
            return str.reverse() // here, we reverse any number token we match
        }),
        vain.regex("[a-zA-Z]+"), // match any letter
        vain.literal("%"), // %
        vain.literal("!")  // !
    ],
    fn (str string) {
        // this is the error callback - the function here is executed if the lexer
        // fails to understand a token. this can happen due to not enough rules,
        // or certain rules being invalid.
        println("error when tokenizing. remaining input: $str") 
    }
)

for {
    // lexer.next() will grab the next token in the lexer
    // once there are no tokens left, the lexer will return none
    token := lexer.next() or {
        break
    }

    println(token)
}
```
