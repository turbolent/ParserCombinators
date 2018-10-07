[![Build Status](https://travis-ci.org/turbolent/ParserCombinators.svg?branch=master)](https://travis-ci.org/turbolent/ParserCombinators)

# ParserCombinators

A *parser-combinator* library for Swift. 

Parsers are simply functions that accept any kind of input, such as strings or custom data structures, and return an output.

Parser combinators are higher-order functions which allow the composition of parsers to create more expressive parsers.

## Examples

For example, a simple calculator with the grammar in BNF can be implemented as follows:

```
<expr>   ::= <term> <addop> <term>     | <term>
<term>   ::= <factor> <mulop> <factor> | <factor>
<factor> ::= '(' <expr> ')' | <num>
<digit>  ::= '0' | '1' | ...
<num>    ::= <digit> | <num> <digit>
<addop>  ::= '+' | '-'
<mulop>  ::= '*' | '/'
```

```swift

import ParserCombinators

typealias Op = (Int, Int) -> Int
typealias OpParser = Parser<Op, Character>

let addOp: OpParser =
    char("+") ^^^ (+) ||
    char("-") ^^^ (-)

let mulOp: OpParser =
    char("*") ^^^ (*) ||
    char("/") ^^^ (/)

let digit = `in`(.decimalDigits, kind: "digit")
let num = digit.rep(min: 1) ^^ { Int(String($0))! }

let expr: Parser<Int, Character> =
    Parser.recursive { expr in
        let factor = (char("(") ~> expr) <~ char(")")
            || num

        let term = factor.chainLeft(
            separator: mulOp,
            min: 1
        ).map { $0 ?? 0 }

        return term.chainLeft(
            separator: addOp,
            min: 1
        ).map { $0 ?? 0 }
    }

let r = CollectionReader(collection: "(23+42)*3")

guard case .success(let value, _) = expr.parse(r) else {
    fatalError()
}

assert(value == 195)
```
