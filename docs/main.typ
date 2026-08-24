#import "@preview/fletcher:0.5.8": *
#import "lib.typ": *

#show raw.where(block: false): box.with(fill: luma(240), inset: (x: 3pt), outset: (y: 3pt), radius: 3pt)
#show raw.where(block: true): it => {
  show raw.line: it => {
    let num_text = text(fill: gray)[#it.number]
    [#num_text #context { h(10pt - measure(num_text).width) } #it.body]
  }
  block(fill: luma(39), inset: 10pt, width: 100%, radius: 4pt, it)
}
#show raw.where(text: str): it => raw(text.trim())
#show raw.where(lang: "いちご"): set text(font: "Noto Sans JP", size: 8pt)
#show raw.where(lang: "rs"): set text(font: "Maple Mono", 8pt)
#show link: underline
#show ref: underline

#show link: set text(fill: blue)
#show ref: set text(fill: blue)
// #show raw.where(block: true): it => {
//   let i = 0
//   set par(justify: false);
//   grid(
//     columns: (100%, 100%),
//     column-gutter: -100%,
//     block(width: 100%, inset: 10pt, for line in it.text.split("\n") {
//       i += 1
//       {
//         set text(size: 10pt)
//         box(width: 0pt, align(right, raw(str(i)) + h(2em)))
//       }
//       hide(line)
//       linebreak()
//     }),
//     block(fill: luma(39), inset: 10pt,　width: 100%,　radius: 4pt, it),
//   )
// }


#show heading.where(level: 1): set text(weight: "medium")
#show heading.where(level: 2): set text(weight: "light", luma(100))
#show heading.where(level: 3): set text(weight: "light", luma(50))
#show heading: it => {
  set text(weight: "regular")
  it
  // if it.level <= 3 { block(smallcaps(it.body)) } else { it }
}

#let title = "Ichigo Programming Language"
#let description = "A compiled language with fully Japanese syntax"

#let info = yaml("name.public.yaml")

#set text(size: 12pt)
#set raw(theme: "ichigo.tmTheme", syntaxes: "ichigo.yaml")
#set document(title: title, description: description)
#set page(numbering: "1 / 1", header: align(right, title))

#set page(margin: 2cm, footer: [
  #set text(size: 8pt)
  *Centre Number:* #info.centre
  #h(1fr) #context counter(page).display("1") #h(1fr)
  *Candidate Number:* #info.candidate
])

#page(
  align(center + horizon)[
    #align(center, text(2.2em)[*#title*])
    #align(center, text(1.2em, description))

    #v(4em)

    #align(center)[
      #text(1.25em)[#info.english] \
      #info.school
    ]

    #v(4em)

    = Abstract
    #align(center, block(width: 80%, align(left, par(justify: true)[
      This project presents the design and implementation of a compiled programming language which is designed to be used by Japanese speakers with a weak English understanding, such as in schools. In a traditional programming language, the source code and documentation is entirely written in English, which is unintuitive for Japanese students with potentially low English comprehension. Therefore, the overall goal is to produce a compiler frontend capable of compiling basic functions and control flow structures but utilizing Japanese keywords for the source code, which includes Japanese-equivalent bindings for common functions like _print_.
    ])))
  ],
)

#set heading(numbering: "1.")

#outline()

= Analysis <analysis>

== Project Scope <project-scope>

This project is limited to developing the compiler _frontend_. The backend, as well as the assembler and linker, will be treated as external, pre-existing components. This is primarily due to the frontend already being a substantial quantity of code, and including additional components such as a backend would exceed the scope of the project due to the development effort required.

To be clear, the compiler frontend is _not_ just a translator from a high level language with Japanese syntax to another higher level language with English syntax. The correct term for a project of this nature would be a _transpiler_#super([@transpiler pp3]), while this project is a _compiler_. This means that it is a significantly more dense project in terms of programming required compared to a basic transpiler. A transpiler would not work for this specific project because it assumes a similar semantic correspondence between the syntax in Japanese and English, which is usually not the case.

== Research <research>

=== How a compiled language works

A compiled language is generally defined as one that is implemented using a _compiler_, which is a program that translates high-level source code into machine code (or another low-level representation) prior to execution. This project focuses exclusively on the implementation of the compiler frontend, however a compiler is typically composed of several idependent components.

A compiler is conventionally organized into a _frontend_ and a _backend_. These parts are responsible for different tasks thoughout the compilation process:

#align(center)[
  #let args = (inset: 1em, corner-radius: 0.25em);
  #diagram(
    node-stroke: .1em,
    spacing: 3em,
    node((0, 0), "Source Code", ..args, name: <src>),
    edge(label: "Lexer", "-|>"),
    node((1, 0), "Token Stream", ..args, name: <tokens>),
    edge(label: "Parser", "-|>"),
    node((2, 0), "Abstract Syntax Tree", ..args, name: <ast>),
    edge(label: "IR Generation", "-|>"),
    node((2, 1), "Intermediate Representation", ..args, extrude: (-2.5, 0), name: <ir>),
    edge(label: "Optimization", "-|>"),
    node((2, 2), "Optimized IR", ..args, name: <opt>),
    edge(label: "Codegen", "-|>"),
    node((1, 2), "Assembly", ..args, name: <asm>),
    edge(label: "Assembler", "-|>"),
    node((0, 2), "Object", ..args, name: <obj>),
    edge(label: "Linker", "-|>"),
    node((0, 1), "Executable", ..args, extrude: (-2.5, 0), name: <exe>),

    node(
      enclose: (<src>, <tokens>, <ast>, <ir>),
      corner-radius: 0.25em,
      name: <frontend>,
      shape: shapes.bracket.with(dir: top, label: [Frontend]),
    ),

    node(
      enclose: (<opt>, <asm>),
      corner-radius: 0.25em,
      name: <backend>,
      shape: shapes.bracket.with(dir: bottom, label: [Backend]),
    ),
  )
]

Frontend tasks typically include:

- _Lexical analysis_ - Tokenize the source code into a stream of tokens consisting of grouped characters, independent of whitespace.
- _Parsing_ - Parse the tokens into an Abstract Syntax Tree.
- _Semantic analysis_ - Perform semantic analysis on the source code for static errors like undefined variables and mismatched types.
- _IR Generation_ - Translate the AST into an intermediate representation (IR), which is a lower level form of the source code.

Backend tasks typically include:

- _Optimization_ - Perform optimizations like dead code elimination, loop unrolling, inlining, and constant folding.
- _ABI Handling_ - Handling calling conventions for the platform, such as the behavior of structs and the stack.
- _Code generation_ - Compile intermediate representation into assembly.

After backend processing, additional steps are required to produce an executable binary:

- _Assembler_ - Translates assembly code into object files (typically one per source file).
- _Linker_ - Resolve symbols (function and variable addresses) and link the program with appropriate libraries to produce the final executable binary.

=== The ASCII character set

When computers were first designed, a simple problem arose where information needed to be displayed on the screen using text. At the time, computers were not a standard concept, and neither was computer science as a topic. As such, the concept of "_displaying characters on the screen_" was only just being invented. However, since computers in the early stages were primarily developed by English-speaking individuals, standards were created to display English characters on the screen in equivalent fashion on multiple computers. These are formally defined by the term _character encodings_.

One of the earliest character encoding schemes was designed with just a few characters in mind, those being the English alphabet in lowercase and uppercase, numbers, and a few extra control characters such as newlines (`\n`), null (`\0`), etc. This encoding scheme is named _ASCII_ and was released in 1963#super([@ascii-timeline]). Its name is an acronym for _American Standard Code for Information Interchange_.

The functionality of ASCII is relatively simple. A single byte can store 8 bits, which means its capacity is 256 numbers. ASCII encodes a unique code point to each number from 0 to 127, which is storable in a 7-bit integer, which means it is often stored in a full byte (a `char` type on most architectures). It is important to note that the first bit of this byte is often unset and can be used as a boolean or for validation. It is also worth noting that this last bit may be used for the _extended_ ASCII codes#super([@ascii-extended]), where characters 128-255 are mapped to accented letters or internationalized characters such as `€`, `Ÿ`, `¥`, `©`, `Æ`, etc. using encodings such as _ISO Latin-1_ (_ISO-8859-1_#super([@iso-latin1])). However, these extended characters are limited, and typically other character encodings such as _GB18030_#super([@GB18030]) or _Unicode_#super([@unicode-ref @unicode]) are preferred, which allow for a significantly higher number of overall characters to be displayed.

ASCII maps the first 32 $[0, 31)$ numbers to _control characters_, which are unprintable characters used to control peripherals such as printers, as well as for purposes such as the newline character (`10`) which is used to determine how a terminal should display multiple lines of text, or the null character (`0`) which is used to terminate strings in low-level languages like C.

The next 32 characters $[32, 64)$ are used for _special characters_ and _digits_. Special characters are miscellaneous printable symbols used in various situations, like `!`, `$`, `%`, `&`, etc. and are defined by the interval $[32, 47] union [58, 64]$. The digits (defined by the interval $(47, 58)$) are the basic Western Arabic digits $0, 1, 2, 3, 4, 5, 6, 7, 8, 9$.

The next 26 characters $[65, 90)$ are used for the _uppercase_ letters $A-Z$. The characters in the range $(97, 122)$ are used for the _lowercase_ letters $a-z$. The rest of the characters, defined by the interval $[91, 96] union [123, 127]$ are used for additional _special characters_, such as `{`, `}`, `[`, `]`, `~`, `^`, etc. Typically, ASCII is represented using a table#super([@ascii]).

=== The Unicode character set <unicode-ref>

When computers began being prevalent around the world, the problem of character encodings shifted. _ASCII_#super([@ascii]), being designed by English-speaking individuals at a time when computers were still a new concept, only included English letters, numbers, and a few symbols, which made it inadequate to represent a larger range of characters found in languages such as Japanese, Chinese, Arabic, Russian, Hindi, etc. As computers grew in popularity rapidly, the problem extended to displaying many _thousands_ of characters, rather than the 128 proposed by ASCII. The solution to this problem is _Unicode_#super([@unicode]), first published in 1991#super([@unicode-release-dates]).

The goal of Unicode is to provide a single, universal way of assigning a unique number (called a _code point_) to every character used in any writing system. This standard allows representation of text in _any language_, rather than just English.

Where ASCII defines just 128 code points $[0–127]$, Unicode defines over 150,000#super([@unicode-chars]). Each code point is an integer, typically written in hexadecimal form, such as `U+0041` for the letter `A`, `U+732B` for the Japanese character `猫` or `U+1F338` for the `🌸` emoji.

These code points are abstract values. To actually store or transmit them in files or across networks, _encoding forms_#super([@unicode-encoding-form]) are used. The most widely used encoding form is _UTF-8_#super([@unicode-utf8]), which is a variable-length encoding that uses 1 to 4 bytes per character and has the property of backward compatibility with ASCII, where the first 128 Unicode code points match ASCII exactly and are stored as single bytes, making existing ASCII text valid UTF-8. Other encodings include _UTF-16_ (using 2 or 4 bytes, typically preferred on Windows™) and _UTF-32_ (always $4$ bytes).

Unicode also defines other aspects of alphabets such as combining characters (such as accents and diacritics), collation (rules to sort text in different languages), and text direction (as in right-to-left scripts like Arabic). Essentialy, Unicode can be thought of as a comprehensive table#super([@unicode-table]) which defines all of the characters that humans use to write, as well as their properties and behaviors. It is the standard encoding throughout operating systems, programming languages, etc.

=== Using Unicode instead of ASCII

As discussed in the previous chapters, _ASCII_ only provides a representation to 128 characters, those being the English alphabet. However, the purpose of this project is to create a programming language with Japanese syntax, which is not part of the ASCII character set. Therefore, a solution must be implemented such that Japanese characters may be tokenized, considering all of the keywords and identifiers will likely be in Japanese. The solution is to use _Unicode_ rather than ASCII, as it is able to represent all Japanese characters required for such a programming language to work. Due to _UTF-8_ being the most common encoding form, it naturally follows that it will also be used for the purpose of this project.

Hiragana is in the Unicode range [`0x3040`, `0x309F`], Katakana is in the range [`0x30A0`, `0x30FF`], and Kanji is in the range [`0x4E00`, `0x9FFF`]. Half-width and full-width digits must also be considered, which are defined by the Unicode ranges [`0x30`, `0x39`] and [`0xFF10`, `0xFF19`] respectively. Finally, Japanese punctuation must be considered, which includes the Japanese quotes (「, 」), comma (、), etc. These characters more spread out throughout the Unicode table, and as such will be discussed in more detail in the documented design#super([@design]) chapter.

=== Tokenization and Lexical Tokens

Lexical analysis is a process where a stream of characters (often called _source code_ if analyzing a program) are converted into meaningful groups of characters called _lexical tokens_, which are then categorized by the lexer depending on the context within the file.

Lexical analysis also exists for natural language, of which the primary purpose is to convert the text into a stream of meaningful lexical tokens with categories such as nouns, verbs, adjectives, punctuation etc. This project implements a programming language rather than natural language, so lexical analysis in _this_ context involves forming a token stream of tokens with categories such as _identifiers_, _keywords_, _punctuation_, and _whitespace_.

Typically, a whitespace-independent tokenizer consumes and discards any whitespace (tabs, spaces, newlines) until a non-whitespace character, and then determines the kind of lexical token to yield based on this character.

A _lexical token_ is a _string_ with an assigned meaning (which may be represented as an enumeration or integer _tag_ in actual implementations). This typically consists of a token name (its category) and an optional value.

A lexer is generally quite simple, and is often classified as the first phase of a compiler frontend in processing. Lexical analysis generally occurs in a single pass, where tokens are yielded in a one-at-a-time fashion from the lexer as it scans the source code.

#pagebreak()
Here is a typical processing diagram for yielding a single token from a lexer:

#align(center)[
  #set text(size: 8pt)
  #let args = (inset: 1em, corner-radius: 0.25em);
  #diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), "Start", ..args, extrude: (-2.5, 0)),
    edge("-|>"),
    node((1, 0), "Characters left?", ..args, shape: shapes.diamond, name: <chars>),
    edge(<whitespace>, "-|>", label: "Yes"),
    edge("-|>", label: "No"),
    node((1, -1), "Return nothing", ..args, extrude: (-2.5, 0)),

    node((2, 0), "Is whitespace?", ..args, shape: shapes.diamond, name: <whitespace>),
    edge("-|>", label: "Yes"),
    edge(<next-char>, "-|>", bend: 24deg, label: "No"),
    node((3, 0), "Consume whitespace", ..args),
    edge("ll", bend: 24deg, "-|>"),

    node((1, 1), "Next character?", ..args, shape: shapes.diamond, name: <next-char>),
    edge(<alpha>, "-|>", bend: -6deg),
    edge(<digit>, "-|>"),
    edge(<punct>, "-|>", bend: 6deg),
    edge(<quote>, "-|>", bend: 6deg),

    node((0, 2), "Alphabetic?", ..args, shape: shapes.diamond, name: <alpha>),
    edge("-|>"),
    node((0, 3), "Consume identifier", ..args),
    edge("-|>", bend: -24deg),
    node((1, 4), "Is keyword?", ..args, shape: shapes.diamond),
    edge("-|>", label: "Yes"),
    edge(<ident>, label: "No", "-|>"),
    node((0.5, 5), "Keyword", ..args),
    edge(<ret>, "-|>", bend: -15deg),
    node((1.5, 5), "Identifier", ..args, name: <ident>),
    edge(<ret>, "-|>"),

    node((1, 2), "Digit?", ..args, shape: shapes.diamond, name: <digit>),
    edge("-|>"),
    node((1, 3), "Consume numeric literal", ..args),
    edge(<ret>, "-|>"),

    node((2, 2), "Punctuation?", ..args, shape: shapes.diamond, name: <punct>),
    edge("-|>"),
    node((2, 3), "Consume punctuation", ..args),
    edge(<ret>, "-|>"),

    node((3, 2), "Left quote?", ..args, shape: shapes.diamond, name: <quote>),
    edge("-|>"),
    node((3, 3), "Consume string literal", ..args),
    edge(<ret>, "-|>"),

    node((2.5, 5), "Return token", ..args, extrude: (-2.5, 0), name: <ret>),

    node(
      enclose: range(-1, 4).map(x => range(-1, 7).map(y => (x, y))).reduce((acc, cur) => (..acc, ..cur)),
      corner-radius: 0.25em,
      name: <frontend>,
      shape: shapes.bracket.with(dir: top, label: [Yielding a single token]),
    ),
  )
]

In practice, a lexer would also contain extra state information like the current position in the file and the file name. One of the common interfaces for interacting with a lexer would be one where you repeatedly call a `next_token()` method, which may return a next token or nothing, if there are no more characters to tokenize.

A lexer for this project would be slightly more interesting however, due to the nature of the characters passed into it. For most "_toy_" compilers, there is a fundamental assumption that the source code input will be in ASCII#super([@ascii]), rather than Unicode#super([@unicode]). This makes it quite simple to tokenize source code using most low-level programming languages (like C), because characters are only a single byte. However, in this project all identifiers and keywords will defined using Japanese words, which means they are multi-byte Unicode characters, called _Unicode scalar values_#super([@unicode-scalar]).

Some languages, such as Rust, have wide character support by default ("The `char` type represents a single character. More specifically, since 'character' isn’t a well-defined concept in Unicode, `char` is a 'Unicode scalar value'."#super([@rust-wide-chars])). This means you are able to iterate over the multi-byte characters easily, making the problem of a tokenizer just as simple as a lower-level language. The language used in this project is Elle#super([@elle]), which is a low-level procedural language. Due to the lower-level nature of it, characters are single bytes. There is also no convenient Unicode handling module in Elle's standard library, which means that it will need to be created specifically for the purpose of this project.

// === How do you parse unicode from bytes?
// === How do you tokenize unicode?
// === What is a token stream?

=== Parsing and Operator Precedence

On its own, a token stream is just an array of meaningful categorized tokens. However, this is not useful for a programming language because there is no relationship between tokens and their semantic meaning in the program. Therefore, the next step in a compiler frontend is _parsing_, which transforms a stream of tokens into an _Abstract Syntax Tree_. This tree describes the abstract relationship between lexical tokens.

There are several categories of parsers for programming languages. For example, a _predictive parser_ is one which does not require any backtracking, and is only usable on the class of `LL(k)` grammars which are the context-free grammars such that there exists some integer _k_ which is the maximum number of tokens to look-ahead to determine which node to parse. A _backtracking recursive descent parser_ is one which produces each node by trying each possible parse path in turn.

A _top-level node_ is one which is not dominated by any other nodes. That is, it does not have any parents; it is at the top of the tree. A _leaf node_ is one which may have a parent, that being another leaf node or a top-level node. A context-free grammar is typically able to differentiate these nodes.

Parsing a single top-level node in a basic _recursive descent_ parser may look like:

#align(center)[
  #set text(size: 8pt)
  #let args = (inset: 1em, corner-radius: 0.25em);
  #diagram(
    node-stroke: .1em,
    spacing: 4em,
    node((0, 0), "Start", ..args, extrude: (-2.5, 0)),
    edge("-|>"),
    node((1, 0), "Tokens left?", ..args, shape: shapes.diamond, name: <tokens>),
    edge(<func>, "-|>", label: "Yes"),
    edge("-|>", label: "No"),
    node((1, -1), "Return nothing", ..args, extrude: (-2.5, 0)),

    node((2, 0), "Function keyword?", ..args, shape: shapes.diamond, name: <func>),
    edge("-|>"),
    node((2, 1), "Consume keyword", ..args),
    edge("-|>"),
    node((1, 1), "Consume and store identifier", ..args),
    edge("-|>"),
    node((0, 1), "Consume left parenthesis", ..args),
    edge("-|>"),
    node((0, 2), "Consume and store arguments", ..args),
    edge("-|>"),
    node((1, 2), "Consume right parenthesis", ..args),
    edge("-|>"),
    node((2, 2), "Consume left brace", ..args),
    edge("-|>"),

    node((2, 3), "Found right brace?", ..args, shape: shapes.diamond, name: <brace>),
    edge(<ret>, "-|>", label: "Yes", bend: 30deg),
    edge("-|>", label: "No"),
    node((1, 3), "Consume and store leaf node", ..args),
    edge("r", "-|>", bend: 30deg),

    node((0, 3), "Return node", ..args, extrude: (-2.5, 0), name: <ret>),

    node(
      enclose: ((1, 1),),
      corner-radius: 0.25em,
      name: <recurse>,
      shape: shapes.bracket.with(dir: top, label: [The function's name]),
    ),

    node(
      enclose: ((0, 2),),
      corner-radius: 0.25em,
      name: <recurse>,
      shape: shapes.bracket.with(dir: bottom, label: [The function's arguments]),
    ),

    node(
      enclose: ((2, 3), (1, 3)),
      corner-radius: 0.25em,
      name: <recurse>,
      shape: shapes.bracket.with(dir: bottom, label: [Parse leaf nodes repeatedly]),
    ),

    node(
      enclose: range(-1, 4).map(x => range(-1, 7).map(y => (x, y))).reduce((acc, cur) => (..acc, ..cur)),
      corner-radius: 0.25em,
      name: <top-level>,
      shape: shapes.bracket.with(dir: top, label: [Parsing a top-level node]),
    ),
  )
]

A top-level node may include any amount of leaf nodes. These nodes can also contain more leaf nodes, hence the structure is a _tree_. In a C-style programming language, functions are considered top-level nodes and statements are considered leaf nodes. A statement is any disambiguated instruction which returns no value. An expression may be included as part of a statement, and typically standalone expressions are also considered valid statements. For example, parsing `int x = foo(5)`. The variable declaration is a _statement_, as it returns no value, however `foo(5)` is an _expression_ contained within the statement. It is also important to notice that `foo(5)` on its is also a valid _statement_, however typically statements cannot be included within other statements.

Parsing a leaf node in a recursive descent parser typically involves a function named `parse_expression()` for parsing _all_ statements, which then calls other specialized functions for parsing _particular_ statements. These statements may parse _expressions_ within their bodies, where an expression which is not part of a statement becomes its own standalone statement. A small-scale example is one with a very basic grammar, consisting purely of function calls and variable declarations. The behaviour for parsing a single leaf node of this basic grammar may be seen below:

#align(center)[
  #set text(size: 8pt)
  #let args = (inset: 1em, corner-radius: 0.25em);
  #diagram(
    node-stroke: .1em,
    spacing: 6em,
    node((0, 0), "Start", ..args, extrude: (-2.5, 0), name: <start>),
    edge("-|>"),
    node((1, 0), "Tokens left?", ..args, shape: shapes.diamond, name: <tokens>),
    edge(<ident>, "-|>", label: "Yes"),
    edge("-|>", label: "No"),
    node((1, -1), "Return nothing", ..args, extrude: (-2.5, 0)),

    node((2, 0), "Expect identifier token", ..args, name: <ident>),
    edge("-|>"),
    node((2, 1), "Next token?", ..args, shape: shapes.diamond, name: <next-kind>),
    edge(<funcall>, "-|>", label: "Left parenthesis", bend: 30deg),
    edge(<var>, "-|>", label: "Identifier", bend: -15deg),
    node((1, 1), "Parse function call", ..args, name: <funcall>),
    edge("-|>"),
    node((1, 2), "Parse parameters", ..args, name: <param>),
    edge((1, 2), (1, 2), "--|>", label: "Recurse", label-pos: 100% - 0.75em, bend: -112deg),
    node((1, 3), "Next token?", ..args, shape: shapes.diamond, name: <rparen>),
    edge(<ret>, "-|>", label: "Right parenthesis"),
    edge(<param>, "-|>", label: "Comma", bend: 30deg),

    node((0, 1), "Parse variable declaration", ..args, name: <var>),
    edge("-|>"),
    node((0, 2), "Expect equals token", ..args, name: <equals>),
    edge("-|>"),
    node((0, 3), "Parse assignment value", ..args, name: <assignment>),
    edge((0, 3), (0, 3), "--|>", label: "Recurse", label-pos: 0.75em, bend: -112deg),
    edge("-|>", bend: 30deg),
    node((0, 4), "Expect termination token", ..args, name: <assignment>),
    edge(<ret>, "-|>"),

    node((1, 4), "Return node", ..args, extrude: (-2.5, 0), name: <ret>),

    node(
      enclose: ((1, 2), (1, 3)),
      corner-radius: 0.25em,
      shape: shapes.bracket.with(dir: right, label: [Function call]),
    ),

    node(
      enclose: ((0, 1), (0, 2), (0, 3), (0, 4)),
      corner-radius: 0.25em,
      shape: shapes.bracket.with(dir: left, label: [Variable\ declaration]),
    ),

    node(
      enclose: range(-1, 4).map(x => range(-1, 7).map(y => (x, y))).reduce((acc, cur) => (..acc, ..cur)),
      corner-radius: 0.25em,
      name: <top-level>,
      shape: shapes.bracket.with(dir: top, label: [Parsing a leaf node]),
    ),
  )
]

In the case of parsing a leaf node, a _recurse_ edge refers to recursively calling the parsing function again. This would return a new leaf node, which would then become a _child_ of the current leaf node. For example, when parsing a variable declaration, you might recurse when parsing its value, which would parse a function call. This function call expression becomes a _leaf node_ inside of the variable declaration node. This way, you can form a _tree_ of semantic relationships to describe the functionality of a program from its syntax.

However, parsing a programming language is usually more complicated. A language typically allows for _operator-precedence_ arithmetic expressions, which involves a more complicated parsing procedure. There are different algorithms for parsing arithmetic, some of which are simpler than others. The most common forms of operator-precedence parsing are the _Shunting Yard Algorithm_#super([@shunting-yard]) and _Pratt Parsing_#super([@pratt-parsing]).

==== Operator Precedence

Operator precedence is a concept derived from mathematics, which is designed to provide predictability to the order in which mathematical expressions are evaluated. For example, in an expression like `1 * 2 + 3 * 4`, the multiplication (`*`) is applied before the addition (`+`), first evaluating to `2 + 12` and finally evaluating to `14`. This concept is extended in computer science, adding more operators such as equality (`==`), logical operators such as `&&` and `||`, and bitwise operators such as `&` and `|`.

#align(center, grid(
  columns: (1fr, 1fr),
  gutter: 3pt,
  block([
    #block(width: 80%, [
      A fully-fledged programming language may have a table such as:
    ])
    #table(
      columns: (auto, auto),
      inset: 10pt,
      align: horizon,
      table.header([*Precedence*], [*Operator*]),
      [11], [`*`, `/`, `%`],
      [10], [`+`, `-`],
      [9], [`..`, `..=` (range)],
      [8], [`<<`, `>>` (bitshift)],
      [7], [`<`, `<=`, `>`, `>=`],
      [6], [`==`, `!=`],
      [5], [`&`, (`and`)],
      [4], [`^`, (`xor`)],
      [3], [`|`, (`or`)],
      [2], [`&&`, (logical `and`)],
      [1], [`||`, (logical `or`)],
    )
  ]),
  block([
    #block(width: 85%)[
      However, Ichigo is a significantly simpler language, so its precedence table would look more similar to:
    ]
    #table(
      columns: (auto, auto),
      inset: 10pt,
      align: horizon,
      table.header([*Precedence*], [*Operator*]),
      [6], [`*`, `/`, `%`],
      [5], [`+`, `-`],
      [4], [`<`, `<=`, `>`, `>=`],
      [3], [`==`, `!=`],
      [2], [`&&`, (logical `and`)],
      [1], [`||`, (logical `or`)],
    )
  ]),
))

==== Reverse Polish Notation <rpn>

The philosophy behind RPN is that evaluation is stack-based, which means that the operators need to be in _postfix_ form rather than _infix_ form. Typically, it works by pushing tokens on a _stack_ until an operator token is found, at which point the top 2 items from the stack are popped, the operator is applied, and the result is pushed back on the stack. If there are no syntactical errors, the outcome will be a stack with a single item in it: the result of the evaluated expression. This is because each evaluation step lowers the amount of items on the stack until a single one remains.

For a postfix expression such as `3 4 - 5 +`, the first token is the number `3`, which is not an operator so it is pushed on the stack. Likewise, the next token is the number `4`, which is also put on the stack. The next token is the mathematical operator `-`, which would pop the top of the stack twice, perform the subtraction, then push the result back on the stack for further processing. The result pushed on the stack would be `-1`. Then, the next token is the number `5`, which is not an operator, so it is pushed on the stack. The last token is the operator `+`, so the top of the stack is popped twice, then the addition operation is performed on these operands, resulting in `4`. This result is lastly pushed on the stack.


==== Shunting Yard Algorithm

The _shunting yard algorithm_#super([@shunting-yard]) is a stack-based algorithm, first invented by _Edsger Dijkstra_ in 1961#super([@shunting-yard-date]), which is used to transform _infix_ expressions such as `1 + 2` into _postfix_ notation (`1 2 +`). Postfix notation may sometimes also be referred to as _Reverse Polish Notation_#super([@rpn]), or RPN. This algorithm is most commonly implemented using a _stack_ (a last-in/first-out construct) for storing operator tokens, and a _queue_ (a first-in/first-out construct) for storing the result.

To convert a basic expression such as `1 + 2` from infix to postfix notation, you would iterate through each token. The first token is the number `1`, so you enqueue it to the _output queue_. The next token is the operator `+`, so you push it to the _operator stack_. The last token is the number `2`, so you enqueue it to the output queue. Finally, pop items from the operator stack until it is empty, and enqueue them to the output queue. The result is an expression in postfix notation, `1 2 +`, rather than the original infix notation, `1 + 2`.

Essentially, the input is processed one token at a time. If the token is not an operator, it is enqueued to the output queue. If it is an operator, and the precedence of it is higher than that of the top of the stack, is is pushed to the top of the stack. Otherwise, all operators on the stack which have a higher precedence than it (or if they has equal precedence, the top of the stack is still popped if the current operator is _left-associative_) are popped from the stack and enqueued to the result queue. Finally the token is pushed to the operator stack. At the end, all remaining tokens in the operator stack are popped and enqueued into the result queue.

For example, in the expression `1 + 2 * 3 - 4`, the first token is the number `1`, which is not an operator token so it is enqueued to the result queue. The next token is the operator `+`, but since there are no other operators on the operator stack, the `+` token is pushed on the stack rather than being enqueued on the result queue. The next token is the number `2`, so it is enqueued on the result queue. The next token is the operator `*`, but since its precedence is higher than the top of the operator stack (`+`), it is pushed to the operator stack rather than the result queue. The next token is the number `3`, so it is enqueued on the result queue. The next token is the operator `-`, but since its precedence is _lower_ than that of the top of the stack (`*`), the top of the queue is popped and enqueued to the result queue. The next token on the operator stack is `+`, and it has the same precedence as `-`. However since `-` is left-associative, the `+` is also popped from the stack and enqueued into the result queue. Finally, the `-` is pushed to the operator stack. The last token is the number `4`, which is enqueued to the result queue. Lastly, the remaining operator(s) in the operator stack (in this case just `-`), are popped from the operator stack and enqueued into the result queue. The resulting expression in postfix is `1 2 3 * + 4 -`.

// === What is an AST?
// === How do you parse operator precedence?
// === How do you parse a function call?
// === How do you parse conditionals?
=== Code Generation

For a modern compilation toolchain, code generation is the stage in which the Abstract Syntax Tree (AST) is traversed and transformed into a flattened form of its higher-level nodes, typically resulting in a _lower-level intermediate representation_ of the program. Earlier compilers often generated assembly directly from AST nodes, and in some cases bypassed the AST altogether, producing assembly directly from tokens.

One of the problems of immediate code generation is that it requires the grammar to be strictly _context-free_, which makes programs with ambiguous grammar difficult, and in some cases impossible, to parse without the usage of an Abstract Syntax Tree.

Even with an Abstract Syntax Tree, generating assembly directly is generally a bad idea, as it requires reimplementing code generation for every target platform at the level of higher-order nodes. This leads to heavy code duplication and combinatorial complexity when changes are inevitably made. A more effective code generation method is to compile into an Intermediate Representation (IR), which acts as a lower-level form of the code but remains platform-agnostic. The IR can then be translated into platform-specific assembly with less duplication. This approach is used by modern compiler toolchains, such as the C compiler _Clang_, which uses the LLVM Intermediate Representation.

// === What is codegen?
=== Arbitrary and Structured Control Flow

Since most intermediate representations do not have _structured control flow_ (such as conditionals and loops), instead opting for _arbitrary control flow_ jumps to particular labels, high level code which uses these constructs must be translated into the arbitrary control flow equivalent. This is not very difficult, however it does require understanding how arbitrary jumps work.

Typically, all you need to create any structured control flow are the following low-level constructs:

- Labels, for arbitrary jumping to particular instructions
- Arbitrary jumps (`jmp`), for jumping unconditionally to a label
- Conditional jumps (`jnz`), for jumping to a label only if the value is non-zero, otherwise jumping elsewhere
- Comparison instructions, such as `eq` and `gt`

You can directly translate an `if` statement to arbitrary control flow by performing its comparison, then jumping to the appropriate block (the _body_ block if the condition is true, otherwise an _end_ block, which continues execution like normal). If the conditional has an `else` branch, you can simply perform another conditional jump in the _end_ block, and continue this infinitely for `else-if` constructions.

A `while` statement is slightly more complicated, but the notion is still very similar. Instead of allowing passthrough the body (like in `if` statements), you must instead unconditionally jump back to the _cond_ block to perform the condition again, which may result in another iteration of the _body_ block if the condition is still _true_.

As such, `for` loops are simply syntax sugar around `while` loops.

```rs
for i := 0; i < 10; i += 1 {
  ...
}
```
```rs
i := 0;

while (i < 10) {
    ...
    i += 1;
}
```

An if statement using arbitrary control flow is translated as follows:

```rs
a := 1;

if a == 5 {
    print(a);
}

...
```

```rs
    a = 1
cond:
    res = eq a, 5
    jnz res, @body @end
body:
    call print(a)
end:
    ...
```

A while loop using arbitrary control flow is translated as follows:

```rs
let a = 5;

while a > 0 {
    print(a);
    a -= 1;
}

...
```

```rs
    a = 5
cond:
    res = gt a, 0
    jnz res @body, @end
body:
    call print(a)
    a = a - 1
    jmp @cond
end:
    ...
```

Similarly, any control flow breaking keywords like `continue` and `break` are extremely simple to implement. For `continue`, just unconditionally jump back to the _cond_ label of the corresponding loop. For `break`, just unconditionally jump to the _end_ label of the corresponding loop.

// === What is intermediate representation?
// === How do you generate intermediate representation?
// === How do you turn an AST into intermediate representation?
// === How do you turn codegen into machine code?
=== Types of compiler backends
Intermediate representation is not a standardized concept. As a result, multiple groups of people have developed distinct solutions for this problem, each with their own design goals and trade-offs.

As such, there is no universally optimal IR; rather, the suitability of a given compiler backend depends on the specific requirements of the project. A non-exhaustive list of commonly used backends may include QBE#super([@qbe]), LLVM#super([@llvm]), Cranelift#super([@cranelift]), and Tilde#super([@tilde]).

For this project, a lightweight intermediate representation is required, as the compilation target is limited to relatively simple constructs such as conditionals and function calls. Therefore, LLVM is instantly excluded from consideration due to its substantial size and complexity#super([@llvm-bloated]).

Similarly, Tilde is ruled out because it is a very recent project with limited documentation, making it impractical for this use case#super([@tilde-docs]). Effective use of this backend would likely require examination of its source code, which is inefficient and time-consuming.

Cranelift, while powerful, is also somewhat too advanced relative to the needs of this project. This leaves QBE as the most appropriate choice. QBE offers a simple design ("QBE is a much smaller scale project with different goals than LLVM."#super([@qbe-llvm-comparison]) while remaining sufficiently expressive using SSA#super([@SSA pp5-10]) to handle all required compilation tasks for this use case.#super([@qbe-docs])

== Similar Projects

- Sabi#super([@sabi]) (written "#text(0.75em)[錆]", meaning "Rust" in Japanese) is a project which translates the Rust programming language#super([@rust]) to Japanese using procedural macros#super([@rust-proc-macro]). It is only similar to Ichigo in terms of syntax, but performs a fundamentally different task. Sabi translates Rust (an existing programming language) keywords into Japanese, while Ichigo's syntax is directly designed with Japanese syntax in mind. It is not translating to another existing high-level language#super([@sabi-proc-macro]) but rather is compiling to a low level intermediate representation.

- Nadesiko 3#super([@nadesiko]) (written "#text(0.75em)[なでしこ]3") is a Japanese programming language. It is based on JavaScript/TypeScript, which means it runs in many different environments. Nadesiko is similar to Ichigo in the fact that it is a Japanese programming language, however the main distinction is the intended usecase for each language. Nadesiko has syntax much more similar to natural Japanese (`「こんにちは」と表示。`, roughly translating to `Display "Hello".`). On the other hand, Ichigo intends to have more traditional syntax, which you would see in a conventional programming language (`プリント（「こんにちは」）。`, roughly translating to `print("Hello");`).

#move(
  [While Nadesiko is designed to make programming in Japanese more comfortable and simple to write code for native speakers, Ichigo has a different purpose in mind, this being that it is designed to make it simpler for beginners to learn (conventionally _English-based_) programming using the procedural paradigm, using familiar Japanese keywords. Addtionally, Nadesiko is also not compiled to a low-level language, instead transpiling to JavaScript#super([@nadesiko-js]) while Ichigo compiles to a low-level intermediate representation.],
  dx: 10pt,
)

== End-user <end-user>

An intended end user of this project is an somebody who is fluent in Japanese but has limited or no proficiency in English, and who may have an interest in learning programming but faces significant barriers due to the prevalence of English-based syntax and terminology in existing languages.

By providing a simple programming language with entirely Japanese syntax and keywords, this project seeks to make programming education more accessible and intuitive for use in Japanese schools at a beginner level.

=== Client interview

A transcript of the conversation with my client may be seen below, translated from Japanese to English:

#{
  let tint(c) = (
    stroke: (paint: c, thickness: 0.5pt, dash: "dashed"),
    fill: rgb(..c.components().slice(0, 3), 2%),
    inset: 8pt,
  )
  set text(size: 10pt)

  let me(it, author: true) = align(right, [
    #box(..tint(color.fuchsia), radius: 0.25em, width: 80%, align(left, it))\
    #if author { text(0.75em)[Me] }
  ])

  let them = (it, author: true) => align(left, [
    #box(..tint(color.purple), radius: 0.25em, width: 80%, align(left, it))\
    #if author { text(0.75em)[Client] }
  ])

  align(center, [
    #them([
      Good evening! \
      \
      I am a teacher at [School Name]. \
      I would like to propose a project to you involving a programming language. \
      \
      Are you interested?
    ])
    #me([Good evening. Of course, could you please provide more detail regarding the requirements for the project?])
    #them(
      [Yes. I would like a compiled programming language which uses Japanese syntax rather than English. It would be used in schools to teach programming to students with low English comprehension, therefore it has to be a simple language.],
    )
    #me(
      [I see. Is there any way you could provide more information involving the features that the language should contain?],
    )
    #them(
      [
        Sure, the language should aim for keywords such as `関数` (function) rather than 'function', including possibly bindings for common functions like `print()` and `input()`
      ],
      author: false,
    )
    #them(
      [The language should have a very basic command line interface, so that students can simply enter a file and get an output executable.],
      author: false,
    )
    #them(
      [It should also have functions, and by extension a `メイン` (main) function. Functions should be callable from other functions.],
      author: false,
    )
    #them(
      [It should have the two basic data types: `整数` (integers) and `文字列` (strings). As this language will be used in schools at a beginner level, more data types are not strictly required but would be a pleasant addition.],
      author: false,
    )
    #them(
      [It also should have variables, which can be defined in functions as well as passed in function calls to other functions. Variables should be able to have any of the two primary data types.],
    )
    #me([Thank you! Are there any other features that the language should have?])
    #them(
      [Just a few. It should control flow constructs like `if` statements and `while` loops, so that they can be tought to students.],
      author: false,
    )
    #them([It should have comments using the `※` character, so that code can be described.], author: false)
    #them(
      [Lastly, it should have numeric literals in the traditional English form (`39`) as well as the Japanese form (`三十九`), as well as string literals using Japanese quotes (`「こんにちは」`).],
    )
    #me(
      [Alright, I will research the information required to create this programming language and get back to you with my findings and a prototype.],
    )
    #them([Great! Thank you very much. I'm looking forward to it.])
  ])
}

Following this interview, I have identified several objectives for the functionality of my project#super([@objectives]).

== Objectives <objectives>

#set enum(numbering: "1.1)", full: true)

+ *Internal behaviour and parsing*
  + The program should be able to load a file from the _Command Line Interface_.
    + The file name should end with `.igo`.
    + If the user does not pass a file, display a help message.
    + If the user passes a file but it does not contain any text, the text is not valid UTF-8, or the file does not exist, an error should be raised and the program should exit.

  + All keywords and syntax should be Japanese characters.
    + This means there is a basic mapping of some keywords like _function_ to _#text(0.75em)[関数]_ and _return_ to _#text(0.75em)[返す]_.
    + Alternatives for some syntax such arithmetic operators should exist (allowing both `+` and `＋`, half-width and full-width characters).
    + String literals should use Japanese quotes (#text(0.75em)[「, 」]) instead of English quotes ("). This also means that strings should be nestable, as the start and end characters are different.
    + Numeric literals should be definable in both the conventional English form (36) and the Japanese form (#text(0.75em)[三十六]).
    + Comments should be defined using the `※` character, rather than the conventional `//` or `#`.

  + The program should tokenize and parse the source code.
  + It should skip comments and whitespace as they only hold semantic meaning to the developer.
  + It should attempt to parse the only top-level node, a function, by expecting the function keyword.
    - Functions are the only supported top-level node in this language.
    + This should be repeated until there are no tokens left to parse.
  + The parser should advance and expect an identifier, and then capture it.
    + The captured identifier is considered the function's name and should be stored in both its plain Unicode form and its hex-encoded form, which is where the Unicode bytes are encoded into a byte-pair string.
  + It should then expect and collect the function's arguments. These should consist of the primary data types in the language.
  + Finally, it should attempt to parse statements until the closing parenthesis is reached. This is considered the function's body, and should be an array of statements.
  + During parsing of the function body, the program should attempt to parse an arithmetic expression.
    + If the statement is not an arithmetic expression, the single expression should be returned.
    + If it is an arithmetic expression, it should be parsed following the standard operator precedence rules.
  + The syntax throughout the language should adhere to the formal definition defined in @formal during the parsing process. If there is a mismatch between the formal syntax and the user's source code, an appropriate error should be raised.
  - This process should result in an _Abstract Syntax Tree_.

+ *Code generation, assembling and linking*
  + The _Abstract Syntax Tree_ generated by the parser should be traversed.
    + Functions should be transformed into an intermediate representation form containing lower-level instructions.
    + Control flow constructs should be transformed into blocks and jumps.
    + Code generation for any statement should be recursive as to allow nested expressions.
    + Variadic functions should be compiled appropriately.
    + The internal structure should be formatted into a textual intermediate representation.
    + If a statement is used in an expression context, an error should be raised.
  + The intermediate representation should be compiled by an external component into assembly.
  + The system assembler and linker should generate an executable with the same name as the original file name (except the extension is stripped). For example `./main.igo` should generate `./main`.
  + The final output should be an executable file.

+ *Behaviour of programs defined in the language*
  + Functions should be allowed to be defined at any point throughout the program, except during the parsing of a function.
  + Functions should be callable within other functions.
  + Function calls should not be validated or type-checked. It is up to the caller to maintain invariants about types, and up to the linker to assert the existence of functions (or rather, their symbols).
  + There should be an entry-point, in this case a #text(0.75em)[メイン] (_main_) function.
    + If the user does not provide an entry-point, an error should be raised and the program should exit.
  + The fundamental data types should exist: #text(0.75em)[整数] (Integer), #text(0.75em)[文字列] (String), etc.
    - Strings are considered untyped pointers (similar to `usize` in Rust or `uintptr_t` in C).
    - Integers are considered 32-bit signed integers.
    - Other data types are not supported.
  + Variables should be definable within a function or the scope of a control flow construct.
    + They must be defined with one of the primary data types.
    + Their value may be any other expression.
    + There should be scoping rules in place which allow you to use outer scope variables in inner scopes but not the opposite.
  + There should be basic control flow constructs, such as _if_ statements and _while_ loops.
    + These constructs should be infinitely nestable.
    + Variables should be definable inside of these constructs.
    + Variables from previous scopes should be usable within the current scope, but not vice-versa.
  + There should be arithmetic and comparison built-in via operators. This also implies the existence of an operator precedence module implemented in the parser for parsing such expressions.
    + Source code such as `x + y` or `x : y`(for equality) should be accepted.
    + Operators should be available in both the Japanese form and the English form, for example multiplication should support both `＊` and `*`.

+ *C Interoperability*
  + The language should aim to implement high-level abstractions of C functions.
    + The `printf` function and any other similar functions should automatically have their variadic delimiters inserted if using an intermediate representation which requires it.
  + Calling C functions should be allowed verbatim by calling the ASCII function's name in the source code. The intermediate representation should handle the passing values to the appropriate registers for the calling convention of the user's platform.
    - Linking to other C libraries is out of the scope of the project, however a lot of the C's standard library functions are automatically linked to your program when compiling with the system C compiler `cc` (which is usually a symbolic link to `gcc` or `clang`).
  + Variable names should be encoded into valid IR form by converting their bytes into hex, and inserting an `_` at the beginning (if the hex string starts with a number, it is no longer a valid identifier).
  + Function names should be quoted and not converted into hex so that their symbol name can be used verbatim and this should be performed for any global identifier. This is because variables (as stated above) only have a semantic meaning and will be stripped, while function names are symbols that will remain _as-is_ in the object file generated later in the compilation pipeline.
  - Taking the address of variables is not a supported feature, as it requires IR-dependent code generation (such as explicit stack allocation) and is outside the scope of this project. This means some C interoperability is not possible (such as `scanf`, which requires to pass a pointer to the variable(s) to write to).

= Documented Design <design>

== Project Organization

- `src`
  - `compiler` - The source code for AST traversal and code generation
    - `lib` - The API to generate a QBE module (as an IR string)
    - `compiler.le` - The implementation of the compiler
  - `lexer` - Tokenization of the source code
    - `enums.le` - The data structures used for tokenization (such as `Token` and `Operator`)
    - `lexer.le` - Tokenization of the source code into an `Iterator<Token, SingleEnded>`
  - `lib` - Various utilities used throughout the project
    - `deque.le` - A basic implementation of a Double-Ended queue in the form of a circular queue with an internal structure of an Array.
    - `encoding.le` - Small utility for turning strings into hexadecimal encodings of themselves.
    - `hashmap.le` - A HashMap implementation using linear probing for storing buckets.
    - `stack.le` - A Basic implementation of a Stack, using an Array internally.
    - `utf8.le` - Encoding a rune into a byte string and vice versa.
  - `parser` - Parsing the tokens into an AST
    - `lib` - Structures used for parsing
    - `parser.le` - Operator-precedence parser to convert an array of tokens into an AST.

== Structure diagram

#align(center)[
  #set text(size: 8pt)
  #let args = (inset: 1em, corner-radius: 0.25em);
  #diagram(
    node-stroke: .1em,
    spacing: 6em,
    node((0, 0), "Entry", ..args, extrude: (-2.5, 0), name: <entry>),
    edge("-|>"),
    node((1, 0), "Lexer", ..args, extrude: (-2.5, 0), name: <lexer>),
    edge("-|>"),
    node((2, 0), "Parser", ..args, extrude: (-2.5, 0), name: <parser>),
    edge("-|>"),
    node((3, 0), "Codegen", ..args, extrude: (-2.5, 0), name: <codegen>),
    node((1, -0.5), "Token", ..args, name: <token>),
    edge("-|>", <lexer>),
    node((0.25, -0.5), "TokenKind", ..args, name: <token-kind>),
    edge("-|>", <token>),
    node((-0.5, -0.5), "Identifier", ..args),
    edge("-|>", <token-kind>),
    node((-0.5, -1), "String", ..args),
    edge("-|>", <token-kind>),
    node((0.9, -1.5), "Number", ..args),
    edge("-|>", <token-kind>),
    node((-0.5, -1.5), "Operator", ..args),
    edge("-|>", <token-kind>),
    node((0.25, -1.5), "Punctuation", ..args),
    edge("-|>", <token-kind>),
    node((1.75, -0.5), "TokenValue", ..args, name: <token-value>),
    edge("-|>", <token>),
    node((1, -1), "Number", ..args),
    edge("-|>", <token-value>),
    node((1.75, -1), "String", ..args),
    edge("-|>", <token-value>),
    node((2.5, -0.5), "Operator", ..args),
    edge("-|>", <token-value>),
    node((1.5, 0.5), "AstNode", ..args, name: <astnode>),
    edge("-|>", <parser>),
    edge("-|>", <function>, bend: 15deg),
    node((2.5, 0.5), "Primitive", ..args, name: <primitive>),
    edge("-|>", <parser>),
    node((3.5, 0.5), "Function", ..args, name: <function>),
    edge("-|>", <primitive>),
    node((-0.5, 1.5), "Literal", ..args),
    edge("-|>", <astnode>),
    node((0.25, 1.5), "BinOp", ..args),
    edge("-|>", <astnode>),
    node((1, 1.5), "FunctionCall", ..args),
    edge("-|>", <astnode>),
    node((1.75, 1.5), "Return", ..args),
    edge("-|>", <astnode>),
    node((2.4, 1.5), "Declare", ..args),
    edge("-|>", <astnode>),
    node((3.05, 1.5), "IfStmt", ..args),
    edge("-|>", <astnode>),
    node((3.75, 1.5), "WhileStmt", ..args),
    edge("-|>", <astnode>, bend: -2deg),
    node((3.25, -0.5), "QbeModule", ..args, name: <qbe-module>),
    edge("-|>", <codegen>),
    node((2.75, -1), "QbeFunction", ..args, name: <qbe-function>),
    edge("-|>", <qbe-module>),
    node((3.75, -1), "QbeData", ..args, name: <qbe-data>),
    edge("-|>", <qbe-module>),
    node((1.75, -1.5), "Argument", ..args, name: <argument>),
    edge("-|>", <qbe-function>),
    node((2.75, -1.5), "QbeBlock", ..args, name: <qbe-block>),
    edge("-|>", <qbe-function>),
    node((2.75, -2), "QbeStatement", ..args, name: <qbe-statement>),
    edge("-|>", <qbe-block>),
    node((2, -2), "QbeValue", ..args, name: <qbe-value>),
    edge("-|>", <qbe-statement>),
    node((2.75, -2.5), "QbeType", ..args, name: <qbe-type>),
    edge("-|>", <qbe-statement>),
    node((3.5, -2.5), "QbeInstr", ..args, name: <qbe-instr>),
    edge("-|>", <qbe-statement>),
    node((0.5, -2.5), "Temporary", ..args),
    edge("-|>", <qbe-value>, bend: -15deg),
    node((1.25, -2.5), "Global", ..args),
    edge("-|>", <qbe-value>),
    node((2, -2.5), "Const", ..args),
    edge("-|>", <qbe-value>),
    node((0.5, -3.5), "Call", ..args),
    edge("-|>", <qbe-instr>),
    node((1.25, -3.5), "Return", ..args),
    edge("-|>", <qbe-instr>),
    node((2, -3.5), "Copy", ..args),
    edge("-|>", <qbe-instr>),
    node((2.75, -3.5), "BinOp", ..args),
    edge("-|>", <qbe-instr>),
    node((3.5, -3.5), "Compare", ..args),
    edge("-|>", <qbe-instr>),
    node((4.25, -3.5), "JMP", ..args),
    edge("-|>", <qbe-instr>),
    node((4.25, -2.5), "JNZ", ..args),
    edge("-|>", <qbe-instr>),
    node((3.75, -1.5), "QbeDataItem", ..args, name: <qbe-data-item>),
    edge("-|>", <qbe-data>),
    node((3.5, -2), "String", ..args),
    edge("-|>", <qbe-data-item>),
    node((4, -2), "Const", ..args),
    edge("-|>", <qbe-data-item>),

    // node((0, 1), "", ..args, shape: shapes.diamond, name: <tokens>),
    // edge(<ident>, "-|>", label: "Yes"),
    // edge("-|>", label: "No"),
    // node((1, -1), "Return nothing", ..args, extrude: (-2.5, 0)),

    // node((2, 0), "Expect identifier token", ..args, name: <ident>),
    // edge("-|>"),
    // node((2, 1), "Next token?", ..args, shape: shapes.diamond, name: <next-kind>),
    // edge(<funcall>, "-|>", label: "Left parenthesis", bend: 30deg),
    // edge(<var>, "-|>", label: "Identifier", bend: -15deg),
    // node((1, 1), "Parse function call", ..args, name: <funcall>),
    // edge("-|>"),
    // node((1, 2), "Parse parameters", ..args, name: <param>),
    // edge((1, 2), (1, 2), "--|>", label: "Recurse", label-pos: 100% - 0.75em, bend: -112deg),
    // node((1, 3), "Next token?", ..args, shape: shapes.diamond, name: <rparen>),
    // edge(<ret>, "-|>", label: "Right parenthesis"),
    // edge(<param>, "-|>", label: "Comma", bend: 30deg),

    // node((0, 1), "Parse variable declaration", ..args, name: <var>),
    // edge("-|>"),
    // node((0, 2), "Expect equals token", ..args, name: <equals>),
    // edge("-|>"),
    // node((0, 3), "Parse assignment value", ..args, name: <assignment>),
    // edge((0, 3), (0, 3), "--|>", label: "Recurse", label-pos: 0.75em, bend: -112deg),
    // edge("-|>", bend: 30deg),
    // node((0, 4), "Expect termination token", ..args, name: <assignment>),
    // edge(<ret>, "-|>"),

    // node((1, 4), "Return node", ..args, extrude: (-2.5, 0), name: <ret>),

    // node(
    //   enclose: ((1, 2), (1, 3)),
    //   corner-radius: 0.25em,
    //   shape: shapes.bracket.with(dir: right, label: [Function call])
    // ),

    // node(
    //   enclose: ((0, 1), (0, 2), (0, 3), (0, 4)),
    //   corner-radius: 0.25em,
    //   shape: shapes.bracket.with(dir: left, label: [Variable\ declaration])
    // ),

    // node(
    //   enclose: range(-1, 4).map(x => range(-1, 7).map(y => (x, y))).reduce((acc, cur) => (..acc, ..cur)),
    //   corner-radius: 0.25em,
    //   name: <top-level>,
    //   shape: shapes.bracket.with(dir: top, label: [Parsing a leaf node])
    // )
  )
]

== Formal grammar <formal>

#embed_code("formal.bnf", "rs")

#align(center, grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 3pt,
  block([
    #block(width: 85%, [
      Translation of the keywords in the language:
    ])
    #table(
      columns: (auto, auto),
      inset: 10pt,
      align: horizon,
      table.header([*Japanese*], [*English*]),
      [`関数`], [function],
      [`返す`], [return],
      [`間`], [while],
      [`もし`], [if],
      [`整数`], [int],
      [`文字列`], [string],
      [`バイト`], [byte],
    )
  ]),
  block([
    #block(width: 85%)[
      Tanslation of all of the Japanese digits supported:
    ]
    #table(
      columns: (auto, auto),
      inset: 10pt,
      align: horizon,
      table.header([*Japanese*], [*English*]),
      [`〇`], [0],
      [`一`], [1],
      [`二`], [2],
      [`三`], [3],
      [`四`], [4],
      [`五`], [5],
      [`六`], [6],
      [`七`], [7],
      [`八`], [8],
      [`九`], [9],
    )
  ]),
  block([
    #block(width: 85%)[
      Translation of all of the Japanese units supported:
    ]
    #table(
      columns: (auto, auto),
      inset: 10pt,
      align: horizon,
      table.header([*Japanese*], [*English*]),
      [`十`], [10],
      [`百`], [100],
      [`千`], [1,000],
      [`万`], [10,000],
    )
  ]),
))

// This is the translation of the different keywords in the language:

// #table(
//   columns: (auto, auto),
//   inset: 10pt,
//   align: horizon,
//   table.header([*Japanese*], [*English*]),
//   [`関数`], [function],
//   [`返す`], [return],
//   [`間`], [while],
//   [`もし`], [if],
//   [`整数`], [int],
//   [`文字列`], [string],
//   [`バイト`], [byte],
// )

// You can also define numeric literals using the Japanese notation for numbers.

// This is a translation of all of the digits:

// #table(
//   columns: (auto, auto),
//   inset: 10pt,
//   align: horizon,
//   table.header([*Japanese*], [*English*]),
//   [`〇`], [0],
//   [`一`], [1],
//   [`二`], [2],
//   [`三`], [3],
//   [`四`], [4],
//   [`五`], [5],
//   [`六`], [6],
//   [`七`], [7],
//   [`八`], [8],
//   [`九`], [9],
// )

// And this is a translation of all of the units supported by the language:

// #table(
//   columns: (auto, auto),
//   inset: 10pt,
//   align: horizon,
//   table.header([*Japanese*], [*English*]),
//   [`十`], [10],
//   [`百`], [100],
//   [`千`], [1,000],
//   [`万`], [10,000],
// )

Japanese numbers are constructed by strings of integer-unit pairs, decreasing in unit. For example, `三十二` is `3-10 2` which is read as 32. You can skip units, so `五千八十四` (read as `5-1000 8-10 4`) is read as 5084. A unit on its own means there is one of that unit, so `百` is equivalent to `一百` (100), not to be confused with `百一` (101).

== Entrypoint (`main.le`)

My project has a very basic form of user input in the form of command line arguments. The user passes the file to compile as an argument to the Ichigo executable.

=== File: `src/main.le`

```rs
fn main(string[] args) -> i32;
```

Extract the executable itself from the 0th command line argument, then extract the file from the 1st command line argument. If the user does not pass a command line argument for the file, they get an error:

`"使い方: {} file.igo".format(program)` or `使い方: ./いちご file.igo`

which translates to:

`"Usage: {} file.igo".format(program)` or `Usage: ./Ichigo file.igo`

If the user did pass a file, but its extension does not end with `.igo`, it throws a different error:

`拡張子が間違っています。「.igo」を使ってください。`

which translates to:

`The file extension is incorrect. Please use ".igo".`

Afterwards, the file is read into a string. If the resulting string is empty (meaning the file is empty), another error should be raised:

`ファイルが空です。`

which translates to:

`The file is empty.`

#div

If the file is not empty (meaning there are possible tokens), a new `Lexer` instance is created and all of the tokens in the string are collected into an array. Afterwards, this array is passed to an instance of the `Parser` and parsed to retrieve an Abstract Syntax Tree (AST). Then, this output is passed to the `Compiler`, and compiled into a `QbeModule`. Finally, the intermediate representation output is written to a file with the same base name but with the extension `ssa` instead of `igo` which is the convention for QBE IR.

== Lexical Analysis (`src/lexer/*`)

My project utilizes a relatively simple lexer which only keeps track of the token's kind and value. The token kind is just an enumeration for various kinds, such as an identifier, string literal, comment, number, operator, or punctuation.

This lexer accepts a string (the source code) as input and yields tokens lazily. Since Ichigo is such a simple language, ambiguities do not exist, so look-ahead and look-back aren't necessary.

For example, source code like:

```いちご
関数　メイン（）『
    返す　〇。
』
```
which translates into:
```rs
fn main() {
    return 0;
}
```

may be tokenized into this list of tokens:

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Number, value = Number(0) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) }
]
```

Of course, this is a relatively simple parsing.

One may parse a more complicated program:

```いちご
関数　同一（整数　値）『
    返す　値。
』

関数　メイン（）『
    整数　テスト＝同一（三十九）。
    プリント（「%d\n」、テスト）。
』
```
which translates into
```rs
fn identity(i32 value) {
    return value;
}

fn main() {
    i32 test = identity(39);
}
```

This program may be tokenized into the following:

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(同一) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) },
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(テスト) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Identifier, value = String(同一) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Number, value = Number(39) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Identifier, value = String(プリント) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = String, value = String(%d\n) },
    Token { kind = Punctuation, value = String(、) },
    Token { kind = Identifier, value = String(テスト) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) }
]
```

The value is a tagged union, which in the context of Elle is just a struct with a tag and all of the possible values:

```rs
enum TokenKind {
    Identifier,
    String,
    Comment,
    Number,
    Operator,
    Punctuation
}

enum ValueKind {
    String,
    Number,
    Operator
}

struct TokenValue {
    ValueKind tag,
    @unused string as_string,
    @unused i64 as_number,
    @unused Operator as_op
}
```

Finally, the token is simply a grouping of these 2 structures:

```rs
struct Token {
    TokenKind kind,
    TokenValue value,
}
```

=== File: `src/lexer/enums.le`

```rs
fn Operator::__fmt__(Operator self, u64 nesting) -> string;
```

This function unwraps the enumeration `Operator` into its enum value, which is a string, and forces this to act as the formatting function for the enum. This means that if you were to format this enum into a string, it would not format to a stringified enumeration key but the enumeration value itself.

#div

```rs
fn Operator::is_comparison(Operator self) -> bool;
```

This function accepts an operator and returns whether the operator is a comparison operator, such as equality or less/greater than.

#div

```rs
fn rune::to_operator(rune self) -> Option<Operator>;
```

This function attempts to convert a rune (UTF-8 code point) into an operator. Will return `Some(Operator)` if the conversion was successful, otherwise will return `None`.

#div

```rs
fn TokenValue::__fmt__(TokenValue self, i32 nesting) -> string;
```

Accepts a TokenValue, and, depending on the tag, will appropriately return the correct string formatting for the value stored inside of the tagged union.

#div

```rs
fn TokenValue::__equals__(TokenValue self, TokenValue other) -> bool;
```

Returns whether `TokenValue` is equal to another TokenValue. For them to be equal, their tag must be the same and the inner value must be equal.

#div

```rs
fn Token::precedence(Token self) -> i32;
```

Accepts a `Token`, asserts that the token is an operator, extracts the operator value, and returns the precedence based on the operator in question, using typical precedence rules.

The rules are as follows:

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  table.header([*Precedence*], [*Operator*]),
  [4], [`*`/`＊`, `/`/`／`, `%`/`％`],
  [3], [`+`/`＋`, `-`/`ー`],
  [2], [`<`/`＜`, `>`/`＞`],
  [1], [`:`/`：`, `!`/`！`],
)

#div

```rs
fn TokenValue::String(string value) -> TokenValue;
fn TokenValue::Number(i64 value) -> TokenValue;
fn TokenValue::Operator(Operator value) -> TokenValue;
```

Constructors for the `TokenValue` struct, setting the correct tag inside of the struct depending on the value type.

#div

```rs
fn TokenValue::is_type(TokenValue self) -> bool;
```

Returns whether a `TokenValue`'s string literal value corresponds to that of a type. For example, the value `整数` (int) would correspond to a type.

#div

```rs
fn Token::__equals__(Token self, Token other) -> bool;
```

Returns whether a `Token` is equal to another `Token`.

＃div

```rs
fn Token::new(TokenKind kind, TokenValue value) -> Token;
```

Constructor for the `Token` structure.

=== File: `src/lexer/lexer.le`

The `Lexer` itself is a basic structure which keeps information such as the file name, input string, and position of the cursor:

```rs
struct Lexer {
    string file,
    string input,
    u64 position
}
```

#div

```rs
fn Lexer::new(string file, string input) -> Lexer;
```

Constructor for the `Lexer` structure.

#div

```rs
fn Lexer::is_eof(Lexer *self) -> bool;
```

Returns whether the `Lexer` is at the end of the input string.

#div

```rs
fn Lexer::current_char(Lexer *self) -> rune;
```

Slices the input string such that it returns up to 4 characters (may be less if near the end of the input), then calls `utf8_decode` on it to get back a `rune` (UTF-8 code point).

#div

```rs
fn Lexer::advance(Lexer *self);
```

If not at the end of the input string, add on to the position the number of bytes of the next UTF-8 code point.

#div

```rs
fn Lexer::skip_whitespace(Lexer *self);
```

Advances the position until the current character is not whitespace.

#div

```rs
fn Lexer::consume_identifier(Lexer *self) -> string;
```

Accepts the lexer by reference, and while not at the end of the input string, and the character is a letter, number, or `_`, push the character into an array of runes and repeat until the character no longer satisfies the requirements or the end of the input is reached.

Finally, encode the array of runes into a single string using `rune[]::utf8_encode`.

#div

```rs
fn Lexer::consume_string_literal(Lexer *self) -> string;
```

Assumes the current character is a `「`, as that is the condition to enter this function. Therefore, instantly advances. While not at the end of the input, keep pushing the current character into an array of runes until the character is `」` (also handling nested strings, such as `「foo「bar」」`, which is a valid string under this convention as the start and end characters are different).

Finally, encode the array of runes into a single string using `rune[]::utf8_encode`.

```rs
fn Lexer::consume_number_literal(Lexer *self) -> i64;
```

While not at the end of the input string and the current character is a number, push it into an array of runes and repeat.

Finally, encode the array of runes into a single string using `rune[]::utf8_encode`, then parse that string into an integer using `i64::parse`.

#div

```rs
fn Lexer::consume_comment(Lexer *self) -> string;
```

While not at the end of the input string and the current character is not a newline, push it into an array of runes and repeat.

Finally, encode the array of runes into a single string using `rune[]::utf8_encode`.

#div

```rs
fn Lexer::consume_jp_numeral(Lexer *self) -> Option<i32>;
```

While not at the end of the input and the current character is a Japanese numeral, read characters one by one and build a numeric value. For cases when `None` is returned, the numeral will be assumed to be an identifier instead.

Digits (`一`/`1` to `九`/`9`, etc.) set the current digit value. In the case that two digits appear in a row, stop and return `None`.

Unit characters (`十`, `百`, `千`, `万`, etc.) multiply the last seen digit, and therefore must appear strictly in a decreasing order, otherwise return `None`. If no digit appears before a unit, the unit iself counts as one of that unit (for example `十 = 10`, but `一十 = 10` too).

The unit and digit maps are defined as follows:

```rs
let jp_digits: rune[] = [0x3007, 0x4E00, 0x4E8C, 0x4E09, 0x56DB, 0x4E94, 0x516D, 0x4E03, 0x516B, 0x4E5D];
let jp_units: HashMap<rune, i32>* = $map($(0x5341, 1e1), $(0x767E, 1e2), $(0x5343, 1e3), $(0x4E07, 1e4));
```

Units below 10,000 are added into a running chunk. Units of 10-000 or larger first finish the current chunk, add it to the total, then reset the chunk, since large units group smaller ones.

Advance after each valid character. If an unknown or invalid Japanese numeral form is found, return `None`.

After the loop, if there is still a value left, add it to the chunk. Finally, return the sum of the total and the chunk as `Some`.

#div

```rs
fn Lexer::next_token(Lexer *self) -> Option<Token>;
```

If the lexer has reached the end of the input string, return `None`, since there are no more tokens left to collect. Otherwise, skip all whitespace.

Depending on the type of the character found, return a different token kind and value in `Some`.

#div

```rs
fn Lexer::iter(Lexer self) -> Iterator<Token, SingleEnded>;
```

Turns the `Lexer` structure into an `Iterator` so that it can be collected into an array directly using `Iterator::collect` instead of needing to do a loop similar to:

```rs
tokens := []Token;

while _, token := lexer.next_token() {
    tokens.push(token);
}

...
```

== Parsing (`src/parser/*`)

The parser for Ichigo is a hand-written, single-pass, operator-precedence parser that builds an AST and a list of top-level primitives from a flat token stream.

It accepts an array of tokens and returns an array of `Primitive` structs, which hold `AstNode` structs inside.

For example, an array of tokens such as:

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Number, value = Number(0) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) }
]
```

may be parsed into:

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = main (main)
        args = []
        body = [
            Return {
                value = Box(Literal {
                    kind = Number
                    value = Number(0)
                })
            }
        ]
    }
]
```

Of course, this is a relatively trivial parse. It would get far more interesting with a more complicated example. For example, this token array:

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(同一) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) },
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(テスト) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Identifier, value = String(同一) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Number, value = Number(39) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Identifier, value = String(プリント) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = String, value = String(%d\n) },
    Token { kind = Punctuation, value = String(、) },
    Token { kind = Identifier, value = String(テスト) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) }
]
```

may parse into:

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = 同一 (_E5908CE4B880)
        args = [
            Argument {
                name = 値 (_E580A4)
                type = 整数 (_E695B4E695B0)
            }
        ]
        body = [
            Return {
                value = Box(Literal {
                    kind = Identifier
                    value = String(値)
                })
            }
        ]
    },
    PrimitiveFunction {
        name = main (main)
        args = []
        body = [
            Declare {
                type = Some(整数 (_E695B4E695B0))
                name = テスト (_E38386E382B9E38388)
                value = Box(FunctionCall {
                    name = 同一 (_E5908CE4B880)
                    args = [
                        Literal {
                            kind = Number
                            value = Number(39)
                        }
                    ]
                })
            },
            FunctionCall {
                name = printf (printf)
                args = [
                    Literal {
                        kind = String
                        value = String(%d\n)
                    },
                    Literal {
                        kind = Identifier
                        value = String(テスト)
                    }
                ]
            }
        ]
    }
]
```

=== File: `src/parser/lib/argument.le`

```rs
struct Argument {
    ObjectString name,
    ObjectString type,
}
```

An argument is a structure that has both a name and a type. The type here is a string because it is handled at code generation. This structure is used for arguments inside of function definitions, not to be confused with parameters (which is the name for the value passed to a function).

#div

```rs
fn Argument::new(string name, string type) -> Argument;
```

Constructor for the `Argument` struct.

=== File: `src/parser/lib/astnode.le`

```rs
enum AstNodeKind {
    Literal,
    BinOp,
    Funcall,
    Return,
    Declare,
    IfStmt,
    WhileStmt
}
```

An enumeration holding all of the different type of top-level statements. Binary operations, literals, function calls, and variable declarations are expressions, however they bubble up to a statement if they are at the top level of a scope.

#div

```rs
struct Literal {
    TokenKind kind,
    TokenValue value,
}
```

A structure holding the kind and value of a literal. This has the same structure as the `Token` struct, however it is different semantically.

#div

```rs
struct BinOp {
    Box<AstNode> left,
    Box<AstNode> right,
    Token op,
}
```

A structure holding the information required to compile a binary operation. The left and right nodes are boxed `AstNode` structs, which are recursive definitions, creating a tree. The operation is a token which is assumed to have a `TokenKind` of `Operator`.

#div

```rs
struct FunctionCall {
    ObjectString name,
    AstNode[] args,
}
```

A structure holding the name of a function and the list of parameters passed to that function as other `AstNode`s.

#div

```rs
struct Return {
    Box<AstNode> value,
}
```

A structure holding the node of the value that should be returned, since you can return any expression (statements being placed here incorrectly is handled at the code generation step).

#div

```rs
struct Declare {
    Option<ObjectString> type,
    ObjectString name,
    Box<AstNode> value,
}
```

A structure holding the name, value, and optionally type of a variable declaration. If the `type` field is `None` (ie, there is no type), it is assumed that the `Declare` should work as a variable _reassignment_ instead of a _declaration_.

#div

```rs
struct IfStmt {
    Box<AstNode> cond,
    AstNode[] body
}
```

A strucutre holding the condition and list of statements which make up a `もし`/`if` statement.

#div

```rs
struct WhileStmt {
    Box<AstNode> cond,
    AstNode[] body
}
```

A strucutre holding the condition and list of statements which make up a `間`/`while` statement.

#div

```rs
struct AstNode {
    AstNodeKind tag,
    @unused Box<Literal> as_literal,
    @unused Box<BinOp> as_binop,
    @unused Box<FunctionCall> as_funcall,
    @unused Box<Return> as_return,
    @unused Box<Declare> as_declare,
    @unused Box<IfStmt> as_if,
    @unused Box<WhileStmt> as_while,
}
```

A structure while acts like a tagged union, and may be one of any of the types of AstNode. The `Box` wrapping ensures that there is no circular dependency resulting in an infinite struct size.

#div

```rs
fn AstNode::__fmt__(AstNode self, i32 nesting) -> string;
```

Returns a different formatted string depending on the tag stored inside of the tagged union.

#div

```rs
fn AstNode::from_token(Token token) -> AstNode;
```

Accepts a token and returns the `Literal` struct in the form of an `AstNode`.

#div

```rs
fn AstNode::BinOp(AstNode left, AstNode right, Token op) -> AstNode;
```

Constructs an `AstNode` with the `BinOp` tag.

#div

```rs
fn AstNode::FunctionCall(string name, AstNode[] args) -> AstNode;
```

Constructs an `AstNode` with the `Funcall` tag.

#div

```rs
fn AstNode::Return(AstNode value) -> AstNode;
```

Constructs an `AstNode` with the `Return` tag.

#div

```rs
fn AstNode::Declare(Option<string> type, string name, AstNode value) -> AstNode;
```

Constructs an `AstNode` with the `Declare` tag.

#div

```rs
fn AstNode::IfStmt(AstNode cond, AstNode[] body) -> AstNode;
```

Constructs an `AstNode` with the `IfStmt` tag.

#div

```rs
fn AstNode::WhileStmt(AstNode cond, AstNode[] body) -> AstNode;
```

Constructs an `AstNode` with the `WhileStmt` tag.

=== File: `src/parser/lib/primitives.le`

```rs
enum PrimitiveKind {
    Function
}

struct PrimitiveFunction {
    ObjectString name,
    Argument[] args,
    AstNode[] body,
}

struct Primitive {
    PrimitiveKind tag,
    PrimitiveFunction as_function,
}
```

This defines "primitives" as in, top-level declarations such as functions. This is future-proofed, as currently functions are the _only_ primitive. However, in the future there may be other primitives like structs, enums, globals, etc.

#div

```rs
fn Primitive::__fmt__(Primitive self, i32 nesting) -> string;
```

Returns a different formatted string depending on the kind of primitive passed as a parameter.

#div

```rs
fn Primitive::Function(string name, Argument[] args, AstNode[] body) -> Primitive;
```

A constructor for the `Primitive` struct with the `Function` tag.

=== File: `src/parser/parser.le`

```rs
struct Parser {
    Token[] tokens,
    Primitive[] tree,
    i32 position,
}
```

A structure which holds the necessary information to parse the array of tokens into an Abstract Syntax Tree.

#div

```rs
fn Parser::new(Token[] tokens) -> Parser;
```

Initializes a `Parser` struct in the default state given a `Token[]`.

#div

```rs
fn Parser::current_token(Parser *self) -> Token;
```

Returns the token in the tokens array at the current position.

#div

```rs
fn Parser::next_token(Parser *self) -> Option<Token>;
```

If there are still tokens left (as in, the position has not reached the end of the token stream yet), then returns the next token without advancing the position. Otherwise, returns `None`. This acts like a "peek" function.

#div

```rs
fn Parser::match_kind(Parser *self, TokenKind kind) -> bool;
fn Parser::match_value(Parser *self, TokenValue value) -> bool;
fn Parser::match_token(Parser *self, Token token) -> bool;
```

Returns true whether the current token's `kind`, `value` or _both_ are equal to the one specified.

#div

```rs
fn Parser::expect_kind(Parser *self, TokenKind kind);
fn Parser::expect_value(Parser *self, TokenValue value);
fn Parser::expect_token(Parser *self, Token token);
```

Panics if the current token's `kind`, `value` or _both_ aren't equal to the one specified. The error raised is `{}が欲しかったのに、{}を手に入れたわ`/`Expected {}, but got {}`.

#div

```rs
fn Parser::advance(Parser *self);
```

Advances the position if not already at the end of the token stream.

#div

```rs
fn Parser::expect_seperator(Parser *self, string sep);
```

Advances, expects a seperator of the expected string, panics if the seperator is not the current token then an error (`{}が欲しかったのに、{}を手に入れたわ`/`Expected {}, but got {}`) is raised. Finally, it advances again.

#div

```rs
fn Parser::parse_funcall(Parser *self) -> AstNode;
```

This function is intended to parse a function call. Therefore, if called, it is implied that the current token is a identifier, so it is saved. Then, the arguments are collected using a recursive call and then the `AstNode` is returned.

#div

```rs
fn Parser::parse_declaration(Parser *self, bool assignment) -> AstNode;
```

This function is intended to parse a variable declaration or reassignment. Therefore, if called, it is implied that the current token is an identifier or a type depending on whether it is declaration or reassignment, so the appropriate one is saved. Then expect equals, advance, and recursively call to parse an expression, and return the `AstNode`.

#div

```rs
fn Parser::parse_primary(Parser *self) -> AstNode;
```

Advance while the current token is a Japanese full stop (`。`). These act like semicolons in this language. This function dispatches the appropriate function depending on what the current token is.

If the token is an identifier:

- If it is `返す`, treat it as a return statement and form a return `AstNode`.
- If it is a type, treat it as the beginning of a variable declaration.
- If the next token is a left parenthesis (`（`), treat it as the beginning of a function call.
- Otherwise, treat it as an identifier literal.

If the token is a string or number, parse it as a literal and return the `AstNode`. If it is a comment, discard it and recursively call `parse_primary` again.

Otherwise, throw an error: `思ったのと違った：{}`/`Unexpected node: {}`

#div

```rs
fn Parser::parse_expr(Parser *self) -> AstNode;
```

Parses an expression using the Shunting Yard algorithm and RPN operations to achieve a operator-precedence parsing of expressions. This allows for precedence-dependent binary operations.

If there is an error when performing RPN on the result queue, an error is raised: `間違った後置記法`/`Incorrect postfix notation`.

A diagram showing how an expression containing arithmetic may be parsed can be viewed below:

#shunting-yard(prelude: true, diagrams: (
  (`1 + 2 * 3 - 4`, `<empty>`, `<empty>`, none, [Initial state, defined in infix notation]),
  (`+ 2 * 3 - 4`, `<empty>`, `1`, ("tok", "res"), [`1` is not an operator so it goes into the result queue]),
  (
    `2 * 3 - 4`,
    `+`,
    `1`,
    ("tok", "op"),
    [`+` is an operator and the stack is empty so it goes into the operator stack],
  ),
  (`* 3 - 4`, `+`, `1 2`, ("tok", "res"), [`2` is not an operator so it goes into the result queue]),
  (
    `3 - 4`,
    `* +`,
    `1 2`,
    ("tok", "op"),
    [`*` is an operator and the top of the stack has a lower precedence so it goes into the operator stack],
  ),
  (`- 4`, `* +`, `1 2 3`, ("tok", "res"), [`3` is not an operator so it goes into the result queue]),
))

#shunting-yard(prelude: false, diagrams: (
  (`- 4`, `+`, `1 2 3 *`, ("op", "res"), [`-` is an operator but the top of the stack has a higher precedence]),
  (
    `- 4`,
    `<empty>`,
    `1 2 3 * +`,
    ("op", "res"),
    [`-` is an operator and top of the stack has equal precedence, but `-` is left-associative],
  ),
  (
    `4`,
    `-`,
    `1 2 * +`,
    ("tok", "op"),
    [`-` is an operator and the stack is now empty so it goes into the opeerator stack],
  ),
  (`<empty>`, `-`, `1 2 3 * + 4`, ("tok", "op"), [`4` is not an operator so it goes into the result queue]),
  (`<empty>`, `<empty>`, `1 2 3 * + 4 -`, ("op", "res"), [The rest of the operators are drained into the result queue]),
))

#div

```rs
fn Parser::parse_if(Parser *self) -> AstNode;
```

Parses an if statement by consuming the condition and body and then returning the `AstNode` formed out of them.

#div

```rs
fn Parser::parse_while(Parser *self) -> AstNode;
```

Parses a while loop by consuming the condition and body and then returning the `AstNode` formed out of them.

#div

```rs
fn Parser::parse_body(Parser *self) -> AstNode[];
```

Parses an array of statements. This means that functions like `parse_if` and `parse_while` are mutually recursive. If it has been determined that the current token is not corresponding to that of a if statement or while loop, an expression is instead parsed and semantically raised to a statement.

#div

```rs
fn Parser::parse_function(Parser *self) -> Primitive;
```

Parses a function declaration at the top-level by collecting its name, arguments, and body, then returns the `AstNode` formed out of them.

#div

```rs
fn Parser::parse(Parser *self) -> Primitive[];
```

This is the top-level parsing function. This function will parse top-level statements like functions. If an invalid state is formed at this stage, an error is raised: `思いがけない：{}`/`Unexpected: {}`. Finally, the tree (specifically Abstract Syntax Tree) is returned.

== Code Generation (`src/compiler/*`)

The compiler generation works by traversing the Abstract Syntax Tree generated by my parser and then compiles it into a module in memory holding all of the information required to be formatted using the standard formatting dunder method in Elle into a QBE IR source file, which can then be compiled into assembly and finally an executable.

The compiler accepts the AST in the form of an array of functions (not function pointers, `Function` structs which hold information about struct definitions). These structs are then compiled by iterating the statements inside their bodies, compiling each recursively.

For example, for an AST like this:

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = main (main)
        args = []
        body = [
            Return {
                value = Box(Literal {
                    kind = Number
                    value = Number(0)
                })
            }
        ]
    }
]
```

Code generation may look like:

```rs
export function l $main() {
@start
	ret 0
}
```

However, for a more complicated example, such as:

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = 同一 (_E5908CE4B880)
        args = [
            Argument {
                name = 値 (_E580A4)
                type = 整数 (_E695B4E695B0)
            }
        ]
        body = [
            Return {
                value = Box(Literal {
                    kind = Identifier
                    value = String(値)
                })
            }
        ]
    },
    PrimitiveFunction {
        name = main (main)
        args = []
        body = [
            Declare {
                type = Some(整数 (_E695B4E695B0))
                name = テスト (_E38386E382B9E38388)
                value = Box(FunctionCall {
                    name = 同一 (_E5908CE4B880)
                    args = [
                        Literal {
                            kind = Number
                            value = Number(39)
                        }
                    ]
                })
            },
            FunctionCall {
                name = printf (printf)
                args = [
                    Literal {
                        kind = String
                        value = String(%d\n)
                    },
                    Literal {
                        kind = Identifier
                        value = String(テスト)
                    }
                ]
            }
        ]
    }
]
```

the code generated in QBE IR may look like:

```rs
export data $tmp.3 = { b "%d\n", b 0 }
export function l $"同一"(l %_E580A4) {
@start
	ret %_E580A4
}
export function l $main() {
@start
	%tmp.1 =l call $"同一"(l 39)
	%_E38386E382B9E38388 =l copy %tmp.1
	%tmp.2 =l call $printf(l $tmp.3, ..., l %_E38386E382B9E38388)
	ret 0
}
```

=== File: `src/compiler/lib/block.le`

```rs
struct QbeBlock {
    string label,
    QbeStatement[] statements,
}
```

A structure containing the name/label of a block, and an array of statements. These are _not_ statements from the Abstract Syntax Tree, they are compiled statements consisting of either an assignment or volatile statement.

#div

```rs
fn QbeBlock::__fmt__(QbeBlock self, i32 nesting) -> string;
```

Formats a `QbeBlock` into a string, in the format:

```rs
@block_name:
    [...stmts]
```

#div

```rs
fn QbeBlock::new(string label) -> QbeBlock;
```

Constructor for the `QbeBlock` struct.

#div

```rs
fn QbeBlock::add_instruction(QbeBlock self, QbeInstr instr);
```

Pushes an instruction into the list of statements as a volatile statement.

#div

```rs
fn QbeBlock::jumps(QbeBlock self) -> bool;
```

Returns whether the current block has an instruction which changes control flow as the last statement.

=== File: `src/compiler/lib/data.le`

```rs
struct QbeData {
    string name,
    (QbeType, QbeDataItem)[] items,
}
```

A structure holding the name and items of a `data` definition, consisting of the type and item of each in a tuple in an array.

#div

```rs
fn QbeData::__fmt__(QbeData self, i32 nesting) -> string;
```

Formats the `QbeData` structure into a string, in the format:

```rs
export data ${name} = { [...items] }
```

=== File: `src/compiler/lib/data_item.le`

```rs
enum QbeDataKind {
    String,
    Const
}

struct QbeDataItemString {
    string inner,
}

struct QbeDataItemConst {
    i64 inner,
}

struct QbeDataItem {
    QbeDataKind tag,
    @unused QbeDataItemString as_string,
    @unused QbeDataItemConst as_const,
}
```

This is a tagged union which holds the different data types which may be inside of a static data definition.

#div

```rs
fn QbeDataItemString::__fmt__(QbeDataItemString self, i32 nesting) -> string;
fn QbeDataItemConst::__fmt__(QbeDataItemConst self, i32 nesting) -> string;
fn QbeDataItem::__fmt__(QbeDataItem self, i32 nesting) -> string;
```

These functions format a `QbeDataItem` into a string which represents the QBE intermediate representation output of the item.

#div

```rs
fn QbeDataItem::String(string inner) -> QbeDataItem;
fn QbeDataItem::Const(i64 inner) -> QbeDataItem;
```

Constructors for the `QbeDataItem` struct.

=== File: `src/compiler/lib/function.le`

```rs
struct QbeFunction {
    ObjectString name,
    Argument[] args,
    QbeType return_type,
    QbeBlock[] blocks,
}
```

A structure holding the information required to compile a function into the QBE intermediate representation. This consists of a `ObjectString` name, as if the name contains any non-ascii characters, it is wrapped in quotes (these can appear in assembly and object files). This structure also holds a list of blocks, which are placed in order into the body of the function.

#div

```rs
fn QbeFunction::__fmt__(QbeFunction self, i32 nesting) -> string;
```

Formats a `QbeFunction` into a string which represents the QBE intermediate representation of the function.

#div

```rs
fn QbeFunction::new(ObjectString name, Argument[] args, QbeType return_type) -> QbeFunction;
```

A constructor for the `QbeFunction` structure.

#div

```rs
fn QbeFunction::add_instruction(QbeFunction *self, QbeInstr instr);
```

Adds the instruction specified into the last block of the function.

#div

```rs
fn QbeFunction::jumps(QbeFunction *self) -> bool;
```

Returns whether the function's last block jumps (see `QbeBlock::jumps`).

=== File: `src/compiler/lib/instr.le`

```rs
enum QbeInstrKind {
    Call,
    Return,
    Copy,
    BinOp,
    Compare,
    JMP,
    JNZ
}
```

An enum which contains a list of all of the possible QBE IR instructions currently implemented into the language.


#div

```rs
pub enum QbeComparison {
    LessThan = "slt",
    LessThanEqual = "sle",
    GreaterThan = "sgt",
    GreaterThanEqual = "sge",
    Equal = "eq",
    NotEqual = "ne",
}
```

An enuneration which acts like a mapping from the comparison name to its instruction mnemonic in QBE IR.

#div

```rs
struct QbeInstrCall {
    QbeValue value,
    (QbeType, QbeValue)[] args,
}

struct QbeInstrReturn {
    QbeValue value,
}

struct QbeInstrCopy {
    QbeValue value,
}

struct QbeInstrBinOp {
    QbeValue left,
    QbeValue right,
    Operator op,
}

struct QbeInstrCompare {
    QbeType type,
    QbeComparison kind,
    QbeValue left,
    QbeValue right
}

struct QbeInstrJMP {
    string label
}

struct QbeInstrJNZ {
    QbeValue value,
    string left,
    string right
}

struct QbeInstr {
    QbeInstrKind tag,
    @unused QbeInstrCall as_call,
    @unused QbeInstrReturn as_return,
    @unused QbeInstrCopy as_copy,
    @unused QbeInstrBinOp as_binop,
    @unused QbeInstrCompare as_compare,
    @unused QbeInstrJMP as_jmp,
    @unused QbeInstrJNZ as_jnz,
}
```

A tagged union containing all of the different instructions and the fields they require to be compiled into QBE IR. Since this tagged union is not recursively implemented, the structs do not require to be boxed.

#div

```rs
fn QbeInstrReturn::__fmt__(QbeInstrReturn self, u32 nesting) -> string;
fn QbeInstrCopy::__fmt__(QbeInstrCopy self, u32 nesting) -> string;
fn QbeInstrBinOp::__fmt__(QbeInstrBinOp self, u32 nesting) -> string;
fn QbeInstrCall::__fmt__(QbeInstrCall self, u32 nesting) -> string;
fn QbeInstrCompare::__fmt__(QbeInstrCompare self, u64 nesting) -> string;
fn QbeInstrJMP::__fmt__(QbeInstrJMP self, u64 nesting) -> string;
fn QbeInstrJNZ::__fmt__(QbeInstrJNZ self, u64 nesting) -> string;
fn QbeInstr::__fmt__(QbeInstr self, i32 nesting) -> string;
```

Functions which format the instruction itself into a valid QBE IR string given the information from their fields, and then finally the `QbeInstr` format function combines them all and dispatches the correct formatting function depending on the tag.

#div

```rs
fn QbeInstr::Call(QbeValue value, (QbeType, QbeValue)[] args) -> QbeInstr;
fn QbeInstr::Return(QbeValue value) -> QbeInstr;
fn QbeInstr::Copy(QbeValue value) -> QbeInstr;
fn QbeInstr::BinOp(QbeValue left, QbeValue right, Operator op) -> QbeInstr;
fn QbeInstr::Compare(QbeType type, QbeComparison kind, QbeValue left, QbeValue right) -> QbeInstr;
fn QbeInstr::JMP(string label) -> QbeInstr;
fn QbeInstr::JNZ(QbeValue value, string left, string right) -> QbeInstr;
```

Constructors for the `QbeInstr` struct which automatically set the required tag of each instruction.

=== File: `src/compiler/lib/module.le`

```rs
struct QbeModule {
    QbeFunction[] functions,
    QbeData[] data_sections,
}
```

A struct containing the information required to compile a single compilation unit into QBE IR. This consists of functions and data sections. Data sections are only required because strings are not first-class citizens of the intermediate language, so string literals must be inserted into their own static data sections and the value becomes a pointer.

#div

```rs
fn QbeModule::__fmt__(QbeModule self, i32 nesting) -> string;
```

Formats a `QbeModule` into valid QBE IR given the functions and data sections specified. Even though QBE does hoist them, this implementation places data sections above functions in the IR.

#div

```rs
fn QbeModule::new() -> QbeModule;
```

Constructor for the `QbeModule` structure. Returns default-state, empty arrays for the functions and data sections.

=== File: `src/compiler/lib/statement.le`

```rs
enum QbeStatementKind {
    Assign,
    Volatile
}
```

An enumeration containing all of the possible kinds of statements supported by QBE.

#div

```rs
struct QbeAssign {
    QbeValue value,
    QbeType type,
    QbeInstr instr,
}

struct QbeVolatile {
    QbeInstr instr,
}

struct QbeStatement {
    QbeStatementKind tag,
    @unused QbeAssign as_assign,
    @unused QbeVolatile as_volatile,
}
```

A tagged union containing the possible QBE statements.

#div

```rs
fn QbeAssign::__fmt__(QbeAssign self, i32 nesting) -> string;
fn QbeVolatile::__fmt__(QbeVolatile self, i32 nesting) -> string;
fn QbeStatement::__fmt__(QbeStatement self, i32 nesting) -> string;
```

Formatter functions for the members of the tagged union which are combined into a single formatter for the base `QbeStatement` tagged union.

#div

```rs
fn QbeStatement::Assign(QbeValue value, QbeType type, QbeInstr instr) -> QbeStatement;
fn QbeStatement::Volatile(QbeInstr instr) -> QbeStatement;
```

Constructors for the `QbeStatement` structure.

=== File: `src/compiler/lib/type.le`

```rs
enum QbeType {
    Int = "整数",
    Long = "文字列",
    Byte = "バイト"
}
```

An enumeration which acts as a mapping from a type name to its Japanese representation:

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  table.header([*Japanese*], [*English*]),
  [`整数`], [int],
  [`文字列`], [string],
  [`バイト`], [byte],
)

#div

```rs
fn QbeType::__hash__(QbeType self, u64 capacity) -> u64;
```

Implements the `__hash__` dunder method for `QbeType` by implicitly casting down to the enum's repr type (string). This is to allow `QbeType` to be used as a key inside of `HashMap`s, since it is a glorified string.

#div

```rs
fn QbeType::__fmt__(QbeType self, i32 nesting) -> string;
```

Implements a formatter for the `QbeType` struct which maps the enum value to its QBE IR representation. For simplicity, normal integers are also treated as 64-bit integers, just like pointers (i.e, they both format to `l`).

#div

```rs
fn QbeType::size(QbeType self) -> i32;
```

Maps the enum value to its size in bytes. The size of integers and longs are the same for simplicity.

=== File: `src/compiler/lib/value.le`

```rs
enum QbeValueKind {
    Temporary,
    Global,
    Const
}
```

An enumeration containing all of the kinds of `QbeValue` accepted by QBE. Temporaries are values such as temporary locals inside of function stack frames, globals are values such as functions and data sections, and consts are values like integer literals. These all carry different sigils, where `Temporary` uses the `%` sigil, `Global` uses the `$` sigil, and `Const` uses none.

#div

```rs
struct Temporary {
    string inner,
}

struct Global {
    string inner,
}

struct Const {
    i64 inner,
}

struct QbeValue {
    QbeValueKind tag,
    @unused Temporary as_temp,
    @unused Global as_global,
    @unused Const as_const,
}
```

A tagged union containing all of the different values available by QBE IR.

```rs
fn Temporary::__fmt__(Temporary self, i32 nesting) -> string;
fn Global::__fmt__(Global self, i32 nesting) -> string;
fn Const::__fmt__(Const self, i32 nesting) -> string;
fn QbeValue::__fmt__(QbeValue self, i32 nesting) -> string;
```

Formatters for the various members of `QbeValue`, which are combined into a single formatter which dispatches the correct formatter depending on the tag stored.

#div

```rs
fn QbeValue::Temporary(string inner) -> QbeValue;
fn QbeValue::Global(string inner) -> QbeValue;
fn QbeValue::Const(i64 inner) -> QbeValue;
```

Constructors for the `QbeValue` struct.

=== File: `src/compiler/lib/qbe.le`

```rs
use value;
use type;
use instr;
use statement;
use block;
use data_item;
use data;
use function;
use module;
global pub;
```

Import glue for all modules in this folder, since they all work together in the compiler.

=== File: `src/compiler/compiler.le`

```rs
struct Compiler {
    QbeModule module,
    Primitive[] tree,
    i32 tmp_counter,
    HashMap<string, (QbeType, QbeValue)> *[] scopes
}
```

A structure containing all of the information required to compile an AST into QBE IR. The `module` field is what is written into throughout the compilation process, the `tree` field is the AST produced by the parser, `tmp_counter` is an integer that is incremented to ensure that all temporaries have unique names, `scopes` is used to enforce lexical scoping rules for variable bindings in `if` statements and `while` loops.

#div

```rs
fn Compiler::new(Primitive[] tree) -> Compiler;
```

Primary constructor for the `Compiler` struct.

#div

```rs
fn Compiler::unique_name(Compiler *self) -> string;
```

Returns a unique name which can be used for a temporary, utilizing `tmp_counter`

#div

```rs
fn Compiler::new_temporary(Compiler *self, string name) -> QbeValue;
```

Creates a new temporary. If the `name` parameter is `nil`, it uses `Compiler::unique_name` for the name of the temporary instead.

#div

```rs
fn Compiler::generate_statement(Compiler *self, AstNode statement, QbeFunction *func) -> Option<(QbeType, QbeValue)>;
```

The primary AST traversal function. This function accepts the compiler instance itself, an `AstNode` which represents a statement and may have further `AstNode` instances inside itself, and the function to compile into. This is because if you compile a compound statement, it will place intermediate instructions into the function and return the final type and temporary.

For example, if you compile:

```rs
返す 値＋1。
```

which translates to:

```rs
return value + 1;
```

It will first compile the inner expression `value + 1`, then it will compile the `return` statement. This is done through recursion, and therefore the return value for this function is an `Option<(QbeType, QbeValue)` and not `(QbeType, QbeValue)` because there may be a case when a statement is compiled inside of another statement, and statements do not produce values, so this would return `None`.

The function checks the tag of the `AstNode` to determine how to interpret it and compile it accordingly.

If the tag is `AstNodeKind::Literal`:
- If it is a number, return it as a `(QbeType::Int, QbeValue::Const(num))`
- If it is an identifier, assume it is a variable binding. Therefore, attempt to search through the list of scopes backwards to find the most recent binding of the variable, and as a result its type and `Temporary` binding name. If a binding is not found in any scope, throw an error (`「{}」という変数はないね`/`Variable "{}" does not exist.`).
- If it is a string literal, escape quotes inside of the string (since it will be wrapped in quotes when placed into the QBE IR), then place it in the current module's `data_sections` along with a null byte after to ensure it is a valid null terminated string. The value produced by this is of type `QbeType::long` and the value is the name of the global generated for the data section.
- Otherwise, throw an error (`間違ったリテラルの型：{}`/`Invalid literal type: {}`)

If the tag is `AstNodeKind::BinOp`:
- Compile recursively the `AstNode` of the left and right nodes of the `BinOp`. Then, store the binary operation into a temporary, add the assignment statement to the last block of the current function, and return the temporary which was assigned.

If the tag is `AstNodeKind::Funcall`:
- Retrieve the name by using its original, unencoded name.
- Attempt to search the module to find the function with this name to retrieve its return type, however if it doesn't exist assume its return type is `QbeType::Int`.
- Compile each argument recursively and push each `(QbeType, QbeValue)` pair into an array. If it attempts to compile but finds `None`, an error is raised (`ステートメントのコンパイルに失敗しました`/`Failed to compile statement`).
- Assign the output call instruction into a temporary and return it.

If the tag is `AstNodeKind::Return`:
- Compile recursively the value stored inside of the return statement.
- Set the current function's return type to the value compiled from this statement.
- Add the statement into the current function.
- Return `None`, since this is a statement.

If the tag is `AstNodeKind::Declare`:
- Compile the value of the variable to be declared
- If the statement's type is `None` this means it is a reassignment, so try to find the variable by resolution through searching the scopes backwards. If it is not found, throw an error (`「{}」という変数はないね`/`Variable "{}" does not exist.`).
- If the variable does exist but its resolved type is of a different size to the one which was just compiled, throw an error (`間違ったタイプ：「{}」と「{}」`/`Incorrect types: {} and {}`). This is a placeholder implementation, before type casting becomes a feature in the language.
- Insert the new type and temporary into the last scope at the binding.
- Return the type and temporary which were compiled.

If the tag is `AstNodeKind::IfStmt`:
- Push a new scope into the stack of scope, create new unique labels using `tmp_counter`, and compile the condition of the statement
- Insert a `JumpNonZero` instruction based on the return value of the condition. This would change the control flow depending on whether the value is zero or not. If it is non-zero, control flow switches to the `body` label. Otherwise, it switches to the `end` label, and the body of the `if` statement is skipped.
- Add a new block with the body label, and compile & insert all of the statements inside of the body. To clarify, these are `AstNode`, not `QbeStatement`, which means they need to be compiled. The return value of these are ignored, since the value returned by each statement when compiled is irrelevant.
- Push the end block, pop the scope which was inserted at the beginning, and return `None` since this is a statement.

If the tag is `AstNodeKind::WhileStmt`:
- Push a new scope into the stack of scope, create new unique labels using `tmp_counter`, and compile the condition of the statement
- Add a new block with the condition label, and compile the condition here. This way, the control flow can be returned back here to check whether the loop should continue after each iteration.
- Insert a `JumpNonZero` instruction based on the return value of the condition. This would change the control flow depending on whether the value is zero or not. If it is non-zero, control flow switches to the `body` label. Otherwise, it switches to the `end` label, and the body of the `while` loop is skipped.
- Add a new block with the body label, and compile & insert all of the statements inside of the body. To clarify, these are `AstNode`, not `QbeStatement`, which means they need to be compiled. The return value of these are ignored, since the value returned by each statement when compiled is irrelevant.
- If there is a last block and it doesn't jump, add an unconditional jump back to the condition label.
- Push the end block, pop the scope which was inserted at the beginning, and return `None` since this is a statement.

Otherwise, panic with an error: `間違ったタグ：{}`/`Invalid tag: {}`, if the statement being compiled has a tag which has not been implemented yet.

#div

```rs
fn Compiler::generate_function(Compiler *self, PrimitiveFunction func) -> QbeFunction;
```

This function is responsible for compiling a function from the AST into valid QBE IR. Since functions have their own scopes, it pushes a new scope, then inserts all arguments as existing variable bindings into the last scope (the one which was just created).

Then, an initial `start` block is created, and all of the statements inside of the function are compiled, ignoring their return value since they may not have any return value.

If the function doesn't jump, it inserts a `return 0` statement at the very end of the last block, then pops the scope and returns the function.

#div

```rs
fn Compiler::compile(Compiler *self) -> QbeModule;
```

This is the primary code generation function. The purpose of this function is to iterate through all top-level constructs in the AST and compile them into a representation which can be formatted into valid QBE IR.

After all functions are compiled into the module, the module is returned. This module is ready to be formatted into a string which will format it into QBE IR.

== Utilities (`src/lib/*`)

=== File: `src/lib/deque.le`

```rs
struct Deque<T> @nofmt {
    T[] data,
    u64 front,
    u64 back,
    u64 size
}
```

A generic structure containing the fields required for a `Deque` to work. It is implemented in terms of a ring-buffer dynamic array.

#div

```rs
fn Deque::new<T>() -> Deque<T>;
```

Constructor for the `Deque` struct.

#div

```rs
fn Deque::__fmt__<T>(Deque<T> self, u64 nesting) -> string;
```

Formats the `Deque` into a string in the form `{ [..values] }`.

#div

```rs
fn Deque::len<T>(Deque<T> self) -> u64;
```

Returns the length of the `Deque`.

#div

```rs
fn Deque::is_empty<T>(Deque<T> self) -> bool;
```

Returns whether the `Deque` is empty.

#div

```rs
fn Deque::push_front<T>(Deque<T> *self, T value);
fn Deque::push_back<T>(Deque<T> *self, T value);
fn Deque::pop_front<T>(Deque<T> *self) -> Option<T>;
fn Deque::pop_back<T>(Deque<T> *self) -> Option<T>;
```

Functions which allow to push and pop from the front or back of the `Deque`.

=== File: `src/lib/encoding.le`

```rs
pub let locale_map: HashMap<string, string> *;
```

A mapping from a Japanese name to its name in English without encoding into hex. This is useful for functions like `main`, the entrypoint.

#div

```rs
fn string::to_hex_bytes(string input) -> string;
```

A function which maps any UTF-8 string into hex bytes. For example, the string `foobar` would be converted into `666F6F626172`. If this has an `_` inserted at the beginning, it allows to encode all UTF-8 identifiers into an ascii representation.

#div

```rs
struct ObjectString {
    string original,
    string encoded,
}
```

A structure containing the original and hex-encoded name of any identifier.

#div

```rs
fn ObjectString::__fmt__(ObjectString self, i32 nesting)
```

A function which formats any `ObjectString` into a string of the form `{original} ({encoded})`.

#div

```rs
fn ObjectString::new(string value) -> ObjectString;
```

A constructor for an `ObjectString` which either uses the `locale_map` or encodes into hex-bytes.

=== File: `src/lib/stack.le`

```rs
struct Stack<T> {
    T[] inner
}
```

A generic structure representing a stack. This stack is implemented in terms of an array.

#div

```rs
fn Stack::new<T>() -> Stack<T>;
```

Constructor for the `Stack` structure.

#div

```rs
fn Stack::push<T>(Stack<T> self, T value);
```

Pushes a value onto the top of the stack. Internally, this just pushes it into the array.

#div

```rs
fn Stack::pop<T>(Stack<T> self) -> Option<T>;
```

Pops a value from the top of the stack. Internally, this just pops from the array. If the stack is empty, this will return `None`.

#div

```rs
fn Stack::peek<T>(Stack<T> self) -> Option<T>
```

Returns a copy of the value at the top of the stack. If the stack is empty, this will return `None`.

#div

```rs
fn Stack::is_empty<T>(Stack<T> self) -> bool;
```

Returns whether the stack is empty or not.

=== File: `src/lib/utf8.le`

Since Elle does not have a standard way of handling UTF-8 or Unicode in general (strings are null terminated and ascii only, the size of a character is 1 byte) this had to be implemented manually. Essentially, a `rune` type was implemented which has the same size as an `i32` (the biggest size required by UTF-8).

```rs
enum rune @repr(i32) @nofmt {}
external fn rune::encode(rune self) @alias(rune::__fmt__) -> string;
external fn i32::__hash__(rune self, u64 capacity) @alias(rune::__hash__) -> u64;
```

The `rune` enum acts as a phony/mock type, since Elle does not have type aliases yet. It is essentially a `distinct i32`.

#div

```rs
let jp_digits: rune[] = [0x3007, 0x4E00, 0x4E8C, 0x4E09, 0x56DB, 0x4E94, 0x516D, 0x4E03, 0x516B, 0x4E5D];
let jp_units: HashMap<rune, i32>* = $map($(0x5341, 1e1), $(0x767E, 1e2), $(0x5343, 1e3), $(0x4E07, 1e4));
```

These globals store the UTF-8 value of the Japanese digits (`〇一二三四五六七八九`) and the first 4 units (`十百千万`).

#div

```rs
fn char::utf8_len(char self) -> i32;
```

Based on the UTF-8 specification, performs bitmasks to decide what the length (in bytes) of the UTF-8 code point is. It may range from 1 (ascii-sized) to 4 (the full `i32`).

#div

```rs
fn string::utf8_decode(string self) -> rune;
```

Based on the UTF-8 specification, and based on the length of the next code point, decodes it into a `rune`. It is the responsibility of the developer to offset the string by the length in bytes of the `rune`.

#div

```rs
fn rune::get_jp_digit(rune self) -> i64;
```

Returns the actual numeric value of a Japanese digit in the form of a `rune`. If it is not a valid digit, it returns `-1`.

#div

```rs
fn rune::get_jp_unit(rune self) -> i32;
```

Returns the numeric unit defined by the unit in the form of a `rune`. If it is not an implemented unit, it returns `0`.

#div

```rs
fn rune::is_jp_numeral(rune self) -> bool;
```

Returns whether this rune is a Japanese digit or unit.

#div

```rs
fn rune::encode(rune self) -> string;
```

Based on the UTF-8 specification, encodes a single rune into a string.

#div

```rs
fn Array::utf8_encode(rune[] self) -> string;
```

Encodes an entire array of runes (`rune[]`) into a string.

#div

```rs
fn rune::is_letter(rune self) -> bool;
```

Returns whether the `rune` is a letter from one of the allowed alphabets. These consist of: `A-Z`, `a-z`, `漢字` (Kanji), `ひらがな` (Hiragana), `カタカナ` (Katakana).

#div

```rs
fn rune::is_number(rune self) -> bool;
```

Returns whether the `rune` is a number from one of the allowed alphabets. These consist of:
- halfwidth digits e.g. 0, 1, 2, ..., 9
- fullwidth digits e.g. ０, １, ２, ..., ９

#div

```rs
fn rune::is_punctuation(rune self) -> bool;
```

Returns whether the `rune` is valid punctuation. This consists of:
- `!, ", #, $, %, &`, ...
- `:, ;, <, =, >, ?`, ...
- `[, \, ], ^, _, ` , ...
- `{, |, }, ~`, ...
- general punctuation e.g. `–, —, •`, ...
- cjk punctuation e.g. `、「」, 、, 。`, ...
- fullwidth forms e.g.`（, ）, ！`, ...


// == Paradigm & Primitives

// == Reading file to parse

// == UTF-8 Parsing

// == Tokenization

// == Parsing

// === Types

// === Functions

// === Variables

// === Control flow

// == AST Traversal

// == Compilation

// == Module to QBE

// == Linking with C

// == Compiling the compiler

// - Define a formal grammar of a high-level programming language where all keywords, operators, etc. are defined using Japanese words. For example, the keyword _function_ would become _#text(0.75em)[関数]_ (function), _return_ would become _#text(0.75em)[返す]_ (return), etc.

// - Implement a tokenizer capable of processing Japanese characters which includes Kanji, Hiragana, and Katakana. As the Elle standard library does not include any Unicode handling module, this component also requires the implementation of a custom Unicode library to handle multi-byte characters.

// - Implement an operator-precedence parser using the recursive descent approach, which should correctly interpret mathematical and general expressions like function calls. The parser will consume the token stream produced by the lexer and build an Abstract Syntax Tree (AST) that represents the syntactic structure of the program.

// - Implement a "code generation" phase that translates the AST into a platform-agnostic intermediate representation (IR), which can then be compiled into an executable by a compiler backend.

// - Add support for numeric literals which Japanese numerals, such as #text(0.75em)[三十六] in place of 36.

= Technical solution

// = #i18n("このイデア", "The Idea")
// == #i18n("こんにちは、世界！", "Hello, world!")
// #code(
//   ```いちご
//   関数　メイン（）『
//   　　　プリント（「こんにちは、世界！」）。
//   』
//   ```,
//   ```rs
//   fn main() {
//     print("Hello, world!");
//   }
//   ```
// )

== Group A Skills

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  table.header([*Skill*], [*Evidence*]),
  [Hash tables/maps],
  [
    - Definition: `src/lib/hashmap.le`
    - Usage: `src/lib/utf8.le:10`, `src/compiler/compiler.le:10`, `src/compiler/compiler.le:38-50`, `src/compiler/compiler.le:119-155`
  ],

  [Lists],
  [`src/parser/parser.le:288-304`, `src/parser/parser.le:316-332`, `src/lexer/lexer.le:45-113`, everywhere where a `T[]` is used],

  [Stacks],
  [
    - Definition: `src/lib/stack.le`
    - Usage: `src/parser/parser.le:201-250`
  ],

  [Queues],
  [
    - Definition: `src/lib/deque.le`
    - Usage: `src/parser/parser.le:201-250`
  ],

  [Trees],
  [
    - Constructing AST: `src/parser/lib/astnode.le`, `src/parser/parser.le`
    - Traversing AST: `src/compiler/compiler.le`
  ],

  [Tree traversal], [`src/compiler/compiler.le:28-209`],
  [List operations],
  [
    - Searching: `src/lib/utf8.le:45`, `src/compiler/compiler.le:86-91`
    - All meets predicate: `src/compiler/lib/value.le:33`, `src/compiler/lib/function.le:17`
    - Iterating/collecting: `src/main.le:18`, `src/compiler/compiler.le:40`
  ],

  [Stack/queue operations], [`src/parser/parser.le:201-250`],
  [Recursive algorithms],
  [
    - Parser: `src/parser/parser.le:152-251`
    - Compiler: `src/compiler/compiler.le:28-209`
  ],

  [Tagged unions],
  [
    Elle does not have tagged unions (or unions for that matter) in the core language yet, however they make this project neater to design, so I implemented them in some form for the necessary purposes:
    - AST Nodes: `src/parser/lib/astnode.le`
    - Top-level constructs: `src/parser/lib/primitives.le`
    - Data item: `src/compiler/lib/data_item.le`
    - Instruction: `src/compiler/lib/instr.le`
    - QBE Statement: `src/compiler/lib/statement.le`
    - QBE Value: `src/compiler/lib/value.le`
  ],

  [Complex algorithms],
  [
    - Shunting Yard Parsing: `src/parser/parser.le:202-236`
    - Rewriting into RPN: `src/parser/parser.le:238-250`
    - Parsing JP numerals: `src/lexer/lexer.le:115-159`
    - Lexical Analysis: `src/lexer/lexer.le:161-230`
    - Constructing AST: `src/parser/lib/astnode.le`, `src/parser/parser.le`
    - Code generation: `src/compiler/compiler.le`
    - Scope resolution:
      - Reassigning an existing variable: `src/compiler/compiler.le:125-129`
      - Retrieving a variable: `src/compiler/compiler.le:39-49`,
      - Entering and exiting a scope during compilation of control flow constructs and functions: `src/compiler/compiler.le:156-179`, `src/compiler/compiler.le:179-206`, `src/compiler/compiler.le:211-237`
    - Formatters (The module is compiled into QBE IR using Elle's formatter system, used in `src/main.le:22`):
      - Block: `src/compiler/lib/block.le:11-21`,
      - Data section: `src/compiler/lib/data.le:12-18`,
      - Data item: `src/compiler/lib/data_item.le:22-38`,
      - Function: `src/compiler/lib/function.le:14-37`,
      - Instruction: `src/compiler/lib/instr.le:74-131`,
      - Module: `src/compiler/lib/module.le:10-22`,
      - Statement: `src/compiler/lib/statement.le:26-42`,
      - Type: `src/compiler/lib/type.le:17-23`,
      - Value: `src/compiler/lib/value.le:28-51`
  ],
)

#for (i, path) in read("srcs.txt").split("\n").enumerate() {
  embed_code("../" + path, "rs")
}

// = #i18n([文法の例「`テスト`」], [Syntax Example "`test`"])

// #code(
//   ```いちご
//   関数　足す（整数　x、整数　y）『
//   　　　返す　x＋y。
//   』

//   関数　同一（整数　x）『
//   　　　返す　x。
//   』

//   関数　メイン（）『
//   　　　※これはコメントです
//   　　　整数　結果　＝　足す（13、26）。
//   　　　整数　あああ　＝　同一（39）。
//   　　　プリント（「こんにちは、世界！」）。
//   　　　プリント（結果、あああ）。
//   』
//   ```,
//   ```rs
//   fn add(x: i32, y: i32) {
//       return x + y;
//   }

//   fn identity(x: i32) {
//       return x;
//   }

//   fn main() {
//       // This is a comment
//       let result: i32 = add(13, 26);
//       let aaa: i32 = identity(39);
//       print("Hello, world!");
//       print(result, aaa);
//   }
//   ```
// )

// = #i18n("インスピレーション", "Inspiration")
// フー、バル、バズ

// = #i18n("どうしてコンパイルですか？", "Why a compiler?")
// フー、バル、バズ

#set page(flipped: true)

= Testing

== Testing table

For all intents and purposes, the errors emitted will _not_ be translated to English since they have already been translated in @design.

#let header(text) = align(center, raw(text))
#let header2(text) = raw(text)

#table(
  columns: (0.75fr, 2fr, 2fr, 3fr),
  inset: 10pt,
  align: horizon,
  table.header([*Objective*], [*Input*], [*Expected Output*], [*Evidence*]),
  header("1.1.1"),
  [File whose name ends with `.igo`],
  [Successful compilation],
  [
    #figure(image("assets/1.1.1/success.png"))
  ],
  header("1.1.1"),
  [File whose name doesn't end with `.igo`],
  [Error stating that the file doesn't end with `.igo`.],
  [
    #figure(image("assets/1.1.1/fail.png"))
  ],
  header("1.1.2"),
  [File which exists],
  [Successful compilation],
  [
    #figure(image("assets/1.1.2/success.png"))
  ],
  header("1.1.2"),
  [File which doesn't exist],
  [Error from POSIX stating that the file doesn't exist.],
  [
    #figure(image("assets/1.1.2/fail.png"))
  ],
  header("1.1.3"),
  [File which contains text (assuming no other compilation issues occur)],
  [Successful compilation],
  [
    #figure(image("assets/1.1.3/success.png"))
  ],
  header("1.1.3"),
  [File which is empty],
  [Error is thrown stating that the file is empty],
  [
    #figure(image("assets/1.1.3/fail.png"))
  ],
  header("1.2.1"),
  [File which contains Japanese equivalents of English keywords],
  [Successful compilation],
  [
    #figure(image("assets/1.2.1/success.png"))
  ],
  header("1.2.1"),
  [File which has English keywords],
  [Compile-time error since those are not valid keywords and are interpreted as identifiers],
  [
    #figure(image("assets/1.2.1/fail.png"))
  ],
  header("1.2.2"),
  [File which contains both half-width and full-width of arithmetic operators],
  [Successful compilation],
  [
    #figure(image("assets/1.2.2/success.png"))
  ],
  header("1.2.2"),
  [File with invalid half-width characters],
  [Compile-time error since this punctuation is not supported as syntax],
  [
    #figure(image("assets/1.2.2/fail.png"))
  ],
  header("1.2.3"),
  [File which has Japanese quotes for strings, including nested strings],
  [Successful compilation],
  [
    #figure(image("assets/1.2.3/success.png"))
  ],
  header("1.2.3"),
  [File which has English quotes],
  [Compilation error since you cannot use these quotes to define strings],
  [
    #figure(image("assets/1.2.3/fail.png"))
  ],
  header("1.2.4"),
  [File which has a return value with English numerals],
  [Compilation success, status code should be correct],
  [
    #figure(image("assets/1.2.4/success1.png"))
  ],
  header("1.2.4"),
  [File which has a return value with Japanese numerals],
  [Compilation success, status code should be correct],
  [
    #figure(image("assets/1.2.4/success2.png"))
  ],
  header("1.2.5"),
  [File with Japanese comments],
  [Successful compilation],
  [
    #figure(image("assets/1.2.5/success.png"))
  ],
  header("1.2.5"),
  [File with English comments (specifically `//`)],
  [Compilation error since the `/` is interpreted as a division, these are not valid characters to be used for comments],
  [
    #figure(image("assets/1.2.5/fail1.png"))
  ],
  header("1.2.5"),
  [File with English comments (specifically `#`)],
  [Compilation error since `#` is not a valid character for a comment],
  [
    #figure(image("assets/1.2.5/fail2.png"))
  ],
  header("1.4"),
  [File with comments and whitespace],
  [Compilation success, should return the same AST as other case],
  [
    #figure(caption: "Passing, file has whitespace and comments", image("assets/1.4/whitespace.png"))
  ],
  header("1.4"),
  [File without comments and whitespace],
  [Compilation success, should return the same AST as other case],
  [
    #figure(caption: "Passing, file has no whitespace and comments", image("assets/1.4/clean.png"))
  ],
  table.cell(
    colspan: 3,
    [#header2("1.5"), #header2("1.5.1"), #header2("1.6"), #header2("1.6.1"), #header2("1.7"), #header2("1.8"), #header2("1.9"), #header2("1.9.1") #header2("1.9.2")],
  ),
  table.cell(colspan: 1, [@fib-ast]),
  align(center)[#header2("2.1"), #header2("2.1.1"), #header2("2.1.5")],
  [File with minimal source code],
  [Transformed into correct QBE Intermediate Representation],
  [
    #figure(image("assets/2.1.1/image.png"))
  ],
  align(center)[#header2("2.1"), #header2("2.1.1"), #header2("2.1.5")],
  [File with complicated source code],
  [Transformed into correct QBE Intermediate Representation],
  [
    #figure(image("assets/2.1.1/image2.png", width: 80%))
  ],
  align(center)[#header2("2.1.2"), #header2("2.1.5"), #header2("3.6"), #header2("3.6.1"), #header2("3.7")],
  [File with control flow constructs `もし` (if) and `間` (while)],
  [Transformed into correct blocks and jumps],
  [
    #figure(image("assets/2.1.2/image.png", width: 80%))
  ],
  align(center)[#header2("2.1.4"), #header2("4.1.1")],
  [File with a variadic function (`プリント`/`printf`)],
  [Program is compiled successfully],
  [
    #figure(image("assets/2.1.4/image.png"))
  ],
  [#header("2.1.6")],
  [File has a statement in a place where an expression is expected],
  [Program fails to compile as statements do not produce a value],
  [
    #figure(image("assets/2.1.6/image.png"))
  ],
  align(center)[#header2("2.2"), #header2("2.3"), #header2("2.4")],
  [File with valid source code],
  [File should be compiled into executable with the same name except without `.igo`. If it produced any executable, this means it also generated valid QBE IR and assembly.],
  [
    #figure(image("assets/2.4/image.png"))
  ],
  align(center)[#header2("3.1"), #header2("3.2"), #header2("3.3"), #header2("3.5")],
  [File with several functions defined at the top-level],
  [Successful compilation],
  [
    #figure(image("assets/3.1/success.png"))
  ],
  align(center)[#header2("3.1"), #header2("3.2"), #header2("3.3")],
  [File with functions defined within itself],
  [Compilation error since you cannot nest function definitions.],
  [
    #figure(image("assets/3.1/fail.png"))
  ],
  header("3.4"),
  [File with a function named `メイン`],
  [Successful compilation],
  [
    #figure(image("assets/3.4/success.png"))
  ],
  header("3.4"),
  [File without a function named `メイン` (named `main` to highlight that you must use the Japanese version of the name)],
  [Compilation error since you must have an entry-point called `メイン`.],
  [
    #figure(image("assets/3.4/fail.png"))
  ],
  header("3.5"),
  [File with integers and strings], [File should compile correctly], [@igo-types],
  align(center)[#header2("3.6.3"), #header2("3.7.3")],
  [File which references a value from an outer scope within an inner scope],
  [Successful compilation],
  [
    #figure(image("assets/3.6.3/success.png"))
  ],
  align(center)[#header2("3.6.3"), #header2("3.7.3")],
  [File which references a value from an inner scope within an outer scope],
  [Compilation error due to lexical scoping rules],
  [
    #figure(image("assets/3.6.3/fail.png"))
  ],
  [#header2("3.7.1"), #header2("3.7.2")],
  [File with nested `if` (`もし`) and `while` (`間`) statements including variable definitions inside of them],
  [File should compile successfully],
  [
    #figure(image("assets/3.7.1/image.png"))
  ],
  table.cell(colspan: 3, [#header2("3.8"), #header2("3.8.1"), #header2("3.8.2")]),
  table.cell(colspan: 1, [@fib-example]),
  header("4.2"),
  [File calling C functions using their ASCII name, without any mapping],
  [Successful compilation],
  [
    #figure(image("assets/4.2/image.png"))
  ],
  header("4.3"),
  [File using variables],
  [Variables should have their names encoded into hex pairs within the intermediate representation to ensure its still ASCII],
  [
    #figure(image("assets/4.3/image.png"))
  ],
  header("4.4"),
  [File using function names consisting of Japanese identifiers],
  [Successful compilation, function names should be quoted in the IR],
  [
    #figure(image("assets/4.4/quoted.png"))
  ],
  header("4.4"),
  [File using function names consisting of English identifiers (ie, ASCII only)],
  [Successful compilation, function names should _not_ be quoted in the IR],
  [
    #figure(image("assets/4.4/unquoted.png"))
  ],
)

#set page(flipped: false)

== Examples

#{
  let data = read("../examples/empty.igo")
  [
    === File: #" " #raw("empty.igo")
    #raw(data, lang: "いちご", block: true)
  ]
}

This program is designed to be the most minimal program which can compile.

==== Translation

```rs
fn main() {}
```

==== Tokens

This acts as a test for `1.3`.

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Punctuation, value = String(』) }
]
```

==== Abstract Syntax Tree

This acts as a test for `1.5`, `1.5.1`, `1.6`, `1.6.1`

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = main (main)
        args = []
        body = []
    }
]
```

==== Code Generation (IR)

```rs
export function l $main() {
@start
	ret 0
}
```

==== Assembly

This acts as a test for `2.2`.
Despite Ichigo not covering this aspect of compilation (it is offloaded to QBE), this IR is transformed into this assembly:

```rs
.text
.balign 4
.globl _main
_main:
	hint	#34
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	mov	x0, #0
	ldp	x29, x30, [sp], 16
	ret
/* end function main */
```

#{
  let data = read("../examples/hello.igo")
  [
    === File: #" " #raw("hello.igo")
    #raw(data, lang: "いちご", block: true)
  ]
}

This program is a typical "Hello, world!" example in Ichigo.

Translation:

```rs
fn main() {
    printf("Hello, world!");
}
```

==== Tokens

This acts as a test for `1.3`.

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(プリント) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = String, value = String(こんにちは、世界！\n) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) }
]
```

==== Abstract Syntax Tree

This acts as a test for `1.5`, `1.5.1`, `1.6`, `1.6.1`, `1.8`, `1.9`, `1.9.1`

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = main (main)
        args = []
        body = [
            FunctionCall {
                name = printf (printf)
                args = [
                    Literal {
                        kind = String
                        value = String(こんにちは、世界！\n)
                    }
                ]
            }
        ]
    }
]
```

==== Code Generation (IR)

```rs
export data $tmp.2 = { b "こんにちは、世界！\n", b 0 }
export function l $main() {
@start
	%tmp.1 =l call $printf(l $tmp.2, ...)
	ret 0
}
```

==== Assembly

This acts as a test for `2.2`.
Despite Ichigo not covering this aspect of compilation (it is offloaded to QBE), this IR is transformed into this assembly:

```rs
.data
.balign 8
.globl _tmp.2
_tmp.2:
	.ascii "こんにちは、世界！\n"
	.byte 0
/* end data */

.text
.balign 4
.globl _main
_main:
	hint	#34
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	adrp	x0, _tmp.2@page
	add	x0, x0, _tmp.2@pageoff
	bl	_printf
	mov	x0, #0
	ldp	x29, x30, [sp], 16
	ret
/* end function main */
```

#{
  let data = read("../examples/types.igo")
  [
    === File: #" " #raw("types.igo") <igo-types>
    #raw(data, lang: "いちご", block: true)
  ]
}

This file acts as a test for `3.5`, and aims to test the different types in the language, as well as function calls.

==== Translation

```rs
fn a(i32 value) { return value; }
fn i(i32 value) { return value; }

fn main() {
    printf("%d, %d\n",
        a(37481),
        i("Hello, world!"));
}
```

==== Tokens

This acts as a test for `1.3`.

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(あ) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) },
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(い) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Identifier, value = String(文字列) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) },
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(プリント) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = String, value = String(%d、%s\n) },
    Token { kind = Punctuation, value = String(、) },
    Token { kind = Identifier, value = String(あ) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Number, value = Number(37481) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(、) },
    Token { kind = Identifier, value = String(い) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = String, value = String(こんにちは、世界！) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) }
]
```

==== Abstract Syntax Tree

This acts as a test for `1.5`, `1.5.1`, `1.6`, `1.6.1`, `1.7`, `1.8`, `1.9`, `1.9.1`

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = あ (_E38182)
        args = [
            Argument {
                name = 値 (_E580A4)
                type = 整数 (_E695B4E695B0)
            }
        ]
        body = [
            Return {
                value = Box(Literal {
                    kind = Identifier
                    value = String(値)
                })
            }
        ]
    },
    PrimitiveFunction {
        name = い (_E38184)
        args = [
            Argument {
                name = 値 (_E580A4)
                type = 文字列 (_E69687E5AD97E58897)
            }
        ]
        body = [
            Return {
                value = Box(Literal {
                    kind = Identifier
                    value = String(値)
                })
            }
        ]
    },
    PrimitiveFunction {
        name = main (main)
        args = []
        body = [
            FunctionCall {
                name = printf (printf)
                args = [
                    Literal {
                        kind = String
                        value = String(%d、%s\n)
                    },
                    FunctionCall {
                        name = あ (_E38182)
                        args = [
                            Literal {
                                kind = Number
                                value = Number(37481)
                            }
                        ]
                    },
                    FunctionCall {
                        name = い (_E38184)
                        args = [
                            Literal {
                                kind = String
                                value = String(こんにちは、世界！)
                            }
                        ]
                    }
                ]
            }
        ]
    }
]
```

==== Code Generation (IR)

```rs
export data $tmp.2 = { b "%d、%s\n", b 0 }
export data $tmp.5 = { b "こんにちは、世界！", b 0 }
export function l $"あ"(l %_E580A4) {
@start
	ret %_E580A4
}
export function l $"い"(l %_E580A4) {
@start
	ret %_E580A4
}
export function l $main() {
@start
	%tmp.3 =l call $"あ"(l 37481)
	%tmp.4 =l call $"い"(l $tmp.5)
	%tmp.1 =l call $printf(l $tmp.2, ..., l %tmp.3, l %tmp.4)
	ret 0
}
```

==== Assembly

This acts as a test for `2.2`.
Despite Ichigo not covering this aspect of compilation (it is offloaded to QBE), this IR is transformed into this assembly:

```rs
.data
.balign 8
.globl _tmp.2
_tmp.2:
	.ascii "%d、%s\n"
	.byte 0
/* end data */

.data
.balign 8
.globl _tmp.5
_tmp.5:
	.ascii "こんにちは、世界！"
	.byte 0
/* end data */

.text
.balign 4
.globl "あ"
"あ":
	hint	#34
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	ldp	x29, x30, [sp], 16
	ret
/* end function "あ" */

.text
.balign 4
.globl "い"
"い":
	hint	#34
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	ldp	x29, x30, [sp], 16
	ret
/* end function "い" */

.text
.balign 4
.globl _main
_main:
	hint	#34
	stp	x29, x30, [sp, -32]!
	mov	x29, sp
	str	x19, [x29, 24]
	mov	x0, #37481
	bl	"あ"
	mov	x19, x0
	adrp	x0, _tmp.5@page
	add	x0, x0, _tmp.5@pageoff
	bl	"い"
	mov	x1, #16
	sub	sp, sp, x1
	mov	x1, #8
	add	x1, sp, x1
	str	x0, [x1]
	mov	x0, #0
	add	x0, sp, x0
	str	x19, [x0]
	adrp	x0, _tmp.2@page
	add	x0, x0, _tmp.2@pageoff
	bl	_printf
	mov	x0, #16
	add	sp, sp, x0
	mov	x0, #0
	ldr	x19, [x29, 24]
	ldp	x29, x30, [sp], 32
	ret
/* end function main */
```

#{
  let data = read("../examples/fib.igo")
  [
    === File: #" " #raw("fib.igo") <fib-example>
    #raw(data, lang: "いちご", block: true)
  ]
}

This program prints the first 30 fibonacci numbers.

==== Translation

```rs
fn fib(i32 value) {
    if value == 1 { return value; }
    i32 prev = i32 i = 1 - i32 now = 1;

    while i < value {
        i32 next = prev + now;
        prev = now; now = next;
        printf("%d: %d\n", i = i + 1, now);
    }

    return now;
}

fn main() {
    printf("\n%d\n", fib(30));
}
```

The structure of this program is deliberately gimmicky to test more of the language at once.

If written cleanly, this program may look like:

#raw(read("../examples/fib_clean.igo"), lang: "いちご", block: true)

which translates to:

```rs
fn fib(i32 value) {
    if value == 1 {
        return value;
    }

    i32 prev = 0;
    i32 i = 0;
    i32 now = 1;

    while i < value {
        i32 next = prev + now;
        prev = now;
        now = next;
        i = i + 1;
        printf("%d: %d\n", i, now);
    }
}

fn main() {
    printf("\n%d\n", fib(30));
}
```

For all intents and purposes, the _*gimmicky*_ version of the program will be used for this test, since it tests more features of the language at once.

==== Tokens

This acts as a test for `1.3`

```rs
[main.le:21:9] Token[] tokens = [
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(フィッブ) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(もし) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Operator, value = Operator(eq) },
    Token { kind = Number, value = Number(1) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(前) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(イ) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Number, value = Number(1) },
    Token { kind = Operator, value = Operator(sub) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(今) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Number, value = Number(1) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Identifier, value = String(間) },
    Token { kind = Identifier, value = String(イ) },
    Token { kind = Operator, value = Operator(slt) },
    Token { kind = Identifier, value = String(値) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(整数) },
    Token { kind = Identifier, value = String(次) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Identifier, value = String(前) },
    Token { kind = Operator, value = Operator(add) },
    Token { kind = Identifier, value = String(今) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Identifier, value = String(前) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Identifier, value = String(今) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Identifier, value = String(今) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Identifier, value = String(次) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Identifier, value = String(プリント) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = String, value = String(%d: %d\n) },
    Token { kind = Punctuation, value = String(、) },
    Token { kind = Identifier, value = String(イ) },
    Token { kind = Punctuation, value = String(＝) },
    Token { kind = Identifier, value = String(イ) },
    Token { kind = Operator, value = Operator(add) },
    Token { kind = Number, value = Number(1) },
    Token { kind = Punctuation, value = String(、) },
    Token { kind = Identifier, value = String(今) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) },
    Token { kind = Identifier, value = String(返す) },
    Token { kind = Identifier, value = String(今) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) },
    Token { kind = Identifier, value = String(関数) },
    Token { kind = Identifier, value = String(メイン) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(『) },
    Token { kind = Identifier, value = String(プリント) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = String, value = String(\n%d\n) },
    Token { kind = Punctuation, value = String(、) },
    Token { kind = Identifier, value = String(フィッブ) },
    Token { kind = Punctuation, value = String(（) },
    Token { kind = Number, value = Number(30) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(）) },
    Token { kind = Punctuation, value = String(。) },
    Token { kind = Punctuation, value = String(』) }
]
```

==== Abstract Syntax Tree <fib-ast>

This acts as a test for `1.5`, `1.5.1`, `1.6`, `1.6.1`, `1.7`, `1.8`, `1.9`, `1.9.1`, `1.9.2`

```rs
[main.le:28:9] Primitive[] tree = [
    PrimitiveFunction {
        name = フィッブ (_E38395E382A3E38383E38396)
        args = [
            Argument {
                name = 値 (_E580A4)
                type = 整数 (_E695B4E695B0)
            }
        ]
        body = [
            IfStmt {
                cond = Box(BinOp {
                    left = Box(Literal {
                        kind = Identifier
                        value = String(値)
                    })
                    right = Box(Literal {
                        kind = Number
                        value = Number(1)
                    })
                    op = Token {
                        kind = Operator
                        value = Operator(eq)
                    }
                })
                body = [
                    Return {
                        value = Box(Literal {
                            kind = Identifier
                            value = String(値)
                        })
                    }
                ]
            },
            Declare {
                type = Some(整数 (_E695B4E695B0))
                name = 前 (_E5898D)
                value = Box(Declare {
                    type = Some(整数 (_E695B4E695B0))
                    name = イ (_E382A4)
                    value = Box(BinOp {
                        left = Box(Literal {
                            kind = Number
                            value = Number(1)
                        })
                        right = Box(Declare {
                            type = Some(整数 (_E695B4E695B0))
                            name = 今 (_E4BB8A)
                            value = Box(Literal {
                                kind = Number
                                value = Number(1)
                            })
                        })
                        op = Token {
                            kind = Operator
                            value = Operator(sub)
                        }
                    })
                })
            },
            WhileStmt {
                cond = Box(BinOp {
                    left = Box(Literal {
                        kind = Identifier
                        value = String(イ)
                    })
                    right = Box(Literal {
                        kind = Identifier
                        value = String(値)
                    })
                    op = Token {
                        kind = Operator
                        value = Operator(slt)
                    }
                })
                body = [
                    Declare {
                        type = Some(整数 (_E695B4E695B0))
                        name = 次 (_E6ACA1)
                        value = Box(BinOp {
                            left = Box(Literal {
                                kind = Identifier
                                value = String(前)
                            })
                            right = Box(Literal {
                                kind = Identifier
                                value = String(今)
                            })
                            op = Token {
                                kind = Operator
                                value = Operator(add)
                            }
                        })
                    },
                    Declare {
                        type = None
                        name = 前 (_E5898D)
                        value = Box(Literal {
                            kind = Identifier
                            value = String(今)
                        })
                    },
                    Declare {
                        type = None
                        name = 今 (_E4BB8A)
                        value = Box(Literal {
                            kind = Identifier
                            value = String(次)
                        })
                    },
                    FunctionCall {
                        name = printf (printf)
                        args = [
                            Literal {
                                kind = String
                                value = String(%d: %d\n)
                            },
                            Declare {
                                type = None
                                name = イ (_E382A4)
                                value = Box(BinOp {
                                    left = Box(Literal {
                                        kind = Identifier
                                        value = String(イ)
                                    })
                                    right = Box(Literal {
                                        kind = Number
                                        value = Number(1)
                                    })
                                    op = Token {
                                        kind = Operator
                                        value = Operator(add)
                                    }
                                })
                            },
                            Literal {
                                kind = Identifier
                                value = String(今)
                            }
                        ]
                    }
                ]
            },
            Return {
                value = Box(Literal {
                    kind = Identifier
                    value = String(今)
                })
            }
        ]
    },
    PrimitiveFunction {
        name = main (main)
        args = []
        body = [
            FunctionCall {
                name = printf (printf)
                args = [
                    Literal {
                        kind = String
                        value = String(\n%d\n)
                    },
                    FunctionCall {
                        name = フィッブ (_E38395E382A3E38383E38396)
                        args = [
                            Literal {
                                kind = Number
                                value = Number(30)
                            }
                        ]
                    }
                ]
            }
        ]
    }
]
```

==== Code Generation (IR)

```rs
export data $tmp.8 = { b "%d: %d\n", b 0 }
export data $tmp.11 = { b "\n%d\n", b 0 }
export function l $"フィッブ"(l %_E580A4) {
@start
	%tmp.2 =l ceqw %_E580A4, 1
	jnz %tmp.2, @body.1, @end.1
@body.1
	ret %_E580A4
@end.1
	%_E4BB8A =l copy 1
	%tmp.3 =l sub 1, %_E4BB8A
	%_E382A4 =l copy %tmp.3
	%_E5898D =l copy %_E382A4
@cond.4
	%tmp.5 =l csltw %_E382A4, %_E580A4
	jnz %tmp.5, @body.4, @end.4
@body.4
	%tmp.6 =l add %_E5898D, %_E4BB8A
	%_E6ACA1 =l copy %tmp.6
	%_E5898D =l copy %_E4BB8A
	%_E4BB8A =l copy %_E6ACA1
	%tmp.9 =l add %_E382A4, 1
	%_E382A4 =l copy %tmp.9
	%tmp.7 =l call $printf(l $tmp.8, ..., l %_E382A4, l %_E4BB8A)
	jmp @cond.4
@end.4
	ret %_E4BB8A
}
export function l $main() {
@start
	%tmp.12 =l call $"フィッブ"(l 30)
	%tmp.10 =l call $printf(l $tmp.11, ..., l %tmp.12)
	ret 0
}
```

==== Assembly

This acts as a test for `2.2`.
Despite Ichigo not covering this aspect of compilation (it is offloaded to QBE), this IR is transformed into this assembly:

```rs
.data
.balign 8
.globl _tmp.8
_tmp.8:
	.ascii "%d: %d\n"
	.byte 0
/* end data */

.data
.balign 8
.globl _tmp.11
_tmp.11:
	.ascii "\n%d\n"
	.byte 0
/* end data */

.text
.balign 4
.globl "フィッブ"
"フィッブ":
	hint	#34
	stp	x29, x30, [sp, -48]!
	mov	x29, sp
	str	x19, [x29, 40]
	str	x20, [x29, 32]
	str	x21, [x29, 24]
	str	x22, [x29, 16]
	cmp	w0, #1
	beq	L6
	mov	x19, #1
	mov	x21, #0
	mov	x20, #0
L2:
	cmp	w21, w0
	bge	L5
	add	x20, x20, x19
	mov	x1, #1
	add	x21, x21, x1
	mov	x1, #16
	sub	sp, sp, x1
	mov	x1, #8
	add	x1, sp, x1
	str	x20, [x1]
	mov	x1, #0
	add	x1, sp, x1
	str	x21, [x1]
	mov	x22, x0
	adrp	x0, _tmp.8@page
	add	x0, x0, _tmp.8@pageoff
	bl	_printf
	mov	x0, x22
	mov	x1, #16
	add	sp, sp, x1
	mov	x18, x20
	mov	x20, x19
	mov	x19, x18
	b	L2
L5:
	mov	x0, x19
L6:
	ldr	x19, [x29, 40]
	ldr	x20, [x29, 32]
	ldr	x21, [x29, 24]
	ldr	x22, [x29, 16]
	ldp	x29, x30, [sp], 48
	ret
/* end function "フィッブ" */

.text
.balign 4
.globl _main
_main:
	hint	#34
	stp	x29, x30, [sp, -16]!
	mov	x29, sp
	mov	x0, #30
	bl	"フィッブ"
	mov	x1, #16
	sub	sp, sp, x1
	mov	x1, #0
	add	x1, sp, x1
	str	x0, [x1]
	adrp	x0, _tmp.11@page
	add	x0, x0, _tmp.11@pageoff
	bl	_printf
	mov	x0, #16
	add	sp, sp, x0
	mov	x0, #0
	ldp	x29, x30, [sp], 16
	ret
/* end function main */
```

which is finally compiled into an executable using the system linker (typically `cc`, `gcc`, `clang`, etc.) This assembly is specifically generated for the MacOS ARM64/aarch64 platform, however QBE can generate assembly for many platforms including `amd64_sysv`, `rv64` (RISC-V), etc.

==== Features Covered

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  table.header([*Feature*], [*Where*]),
  [Functions],
  [
    This includes function definitions with and without arguments:
    ```いちご
      関数　フィッブ（整数　値）
    ```
    ```いちご
      関数　メイン（）
    ```

    Translation:
    ```rs
    fn fib(i32 value)
    ```
    ```rs
    fn main()
    ```
  ],

  [If statements],
  [
    ```いちご
      もし　値：一 『返す　値。』
    ```
    Translation:
    ```rs
    if value == 1 { return value; }
    ```
  ],

  [While loops],
  [
    ```いちご
      間　イ＜値
    ```
    Translation:
    ```rs
    while i < value
    ```
  ],

  [Conditions],
  [
    ```いちご
      値：一
    ```
    ```いちご
      イ＜値
    ```
    Translation:
    ```rs
    value == 1
    ```
    ```rs
    i < value
    ```
  ],

  [Arithmetic],
  [
    ```いちご
      整数　イ＝一ー整数　今＝一
    ```
    ```いちご
      前＋今
    ```
    ```いちご
      イ＝イ＋一
    ```
    Translation:
    ```rs
    i32 i = 1 - i32 now = 1
    ```
    ```rs
    prev + now
    ```
    ```rs
    i = i + 1
    ```

    Some things to note:
    - Variable declarations are expressions which return the rvalue which was declared (or rather, a copy of it).

    - `一` and `ー` are different Kanji. The first one is "one/1", the second one is "subtract". Despite them looking similar, they are treated differently by the language. This is why you are able to correctly write:

    ```いちご
    一ー整数　今＝一
    ```
  ],

  [Return values],
  [
    ```いちご
      返す　今。
    ```
    Translation:
    ```rs
    return now;
    ```
  ],

  [Calling functions],
  [
    ```いちご
      プリント（「%d: %d\n」、イ＝イ＋一、今）。
    ```
    ```いちご
      プリント（「\n%d\n」、フィッブ（三十））。
    ```
    Translation:
    ```rs
    printf("%d, %d\n", i = i + 1, now);
    ```
    ```rs
    printf("\n%d\n", fib(100));
    ```
  ],

  [Japanese numerals],
  [
    ```いちご
      値：一
    ```
    ```いちご
      整数　イ＝一ー整数　今＝一。
    ```
    ```いちご
      イ＝イ＋一
    ```
    ```いちご
      フィッブ（三十）
    ```
    Translation:
    ```rs
    value == 1
    ```
    ```rs
    i32 i = 1 - i32 now = 1
    ```
    ```rs
    i = i + 1
    ```
    ```rs
    fib(30)
    ```
  ],
)

= Evaluation

== Overall Reflection

I believe that my project meets all of the objectives which I set out at the beginning of my project. Some compromises had to be made, such as single-character arithmetic operators (ie `:` for `==`) due to the way that my UTF-8 library is implemented, which means it only returns a single `rune` out of the string. If I had more time, I would rewrite the UTF-8 library to return an array of `rune`, allowing for multi-character operators. Additionally, I believe that detrimental features are still missing from the language from a compilation standpoint, which makes it flawed for use in real software development (disregarding the Japanese syntax gimmick). However, for the purpose of use in schools, I believe the language is usable enough to provide an elevated learning experience.

== Objective Reflection

+ *Internal behaviour and parsing*
  + The program does load the program to compile from the command line interface, so I believe this point was met.
    + There are checks in place to ensure the file name ends with `.igo`, so this point was met.
    + A help message is displayed, so this point was met.
    + There are checks for if the file does not contain any text, but files which contain only comments are not checked. Additionally, if the file doesn't exist an error is also raised. Therefore, this point was mostly met.

  + This point was met, as all keywords are Japanese words.
    + English keywords were mapped to Japanese, so this point was met.
    + Alternatives exist but only for arithmetic and comparison operators, other punctuation like `{` instead of `『` is not valid, so this point was mostly met.
    + This point was met as strings use _only_ Japanese quotes, and English quotes throw a parsing error since they are not valid punctuation for defining string literals.
    + This point was entirely met as you can define integer literals via both English numerals and Japanese numerals. Malformed Japanese numerals do not throw an error and instead are interpreted as an identifier, which is incorrect and should be improved for the future.
    + This point was entirely met as Japanese comments work correctly and English punctuation for them throws an independent parsing error.

  + This point was entirely met throughout all tests and examples which were not intended to fail before lexical analysis.
  + This point was met and verified by a test of source code with comments and whitespace compiling to the same IR as one without comments and whitespace.
  + This point was met as functions are the only supported form of top-level node.
    + This point was met as the parser loops until it reaches the end of the token stream.
  + This point was met and verified by several example programs.
    + This point was met as it is converted into an `ObjectString`.
  + This point was met and verified by several example programs which accept arguments of various data types.
  + This point was entirely met and verified by all example programs.
  + This point was met and verified by any example programs which contain arithmetic expressions.
  + This point was generally met and verified by all example programs.

+ *Code generation, assembling and linking*
  + The compiler does traverse the top-level functions and then statements inside of the functions recursively, so this point was entirely met.
    + This was met as functions are compiled into QBE IR.
    + This was met for `もし` (`if`) and `間` (`while`) and verified from various examples that this is working, including for nested control flow constructs.
    + This was entirely met as most expressions are compound (function calls, arithmetic expressions, etc).
    + This was met for any examples which called `printf`.
    + This was entirely met as all valid examples were compiled into QBE Intermediate Representation which is a textual IR.
    + This was met as in the case of a statement being used in an expression context, `None` is returned and the program panics.
  + This point was met as it was verified that QBE does translate my IR generated into valid `arm64` assembly.
  + This point was entirely met.

+ *Behaviour of programs defined in the language*
  + This was met and verified by a test to ensure several functions can be defined at the top-level but nested functions will throw an error.
  + This point was met and verified by almost all examples which call functions.
  + This point was met.
  + This point was met and the entry was aliased to `メイン` instead of `main`.
    + This point was entirely met as a case was added explicitly to ensure the entry-point exists, and this was tested.
  + This point was met to some degree, as `整数` (int) and `文字列` (string) were added to the language. Other types, while nice to have, were not added.
  + This point was entirely met by proxy due to control flow constructs using the same parsing function for their body as the top-level of function definitions.
    + This point was mostly met, however when variables are reassigned, they are not required to have one of the primary data types.
    + This point was entirely met, it is important that the term is _expression_ and not _statement_.
    + There should be scoping rules in place which allow you to use outer scope variables in inner scopes but not the opposite.
  + This point has been entirely met since the language has `if` statements and `while` loops.
    + This point was entirely met and tested several times.
    + As stated in the previous points, the control flow constructs use the same method to parse the body as function definitions, so this point has been met.
    + If you attempt to access a variable from an outer scope in an inner scope, it will work. However, vice versa will throw a compilation error. Therefore, this point has been met.
  + This point has been implemented as there is an operator-precedence section within the parser which handles arithmetic operators and comparison operators.
    + This point has been met and verified in several tests.
    + This point has been partially implemented, except only for binary operators, so punctuation like the Japanese comma, parenthesis, brackets, etc.

+ *C Interoperability*
  + This point has been partially implemented, since the only function which has a mapping is `printf`.
    + This has been met and verified by several examples which interact with the IR.
  + This has been fully met and has been verified to work in tests, calling `libc` functions.
  + This has been met and was verified within a test to correctly produce variable names which always consist of valid ASCII.
  + This has been met and was verified within a test to correctly produce quoted function names if there is any UTF-8 in the name at all.

== Client Feedback

#{
  let tint(c) = (
    stroke: (paint: c, thickness: 0.5pt, dash: "dashed"),
    fill: rgb(..c.components().slice(0, 3), 2%),
    inset: 8pt,
  )
  set text(size: 10pt)

  let me(it, author: true) = align(right, [
    #box(..tint(color.fuchsia), radius: 0.25em, width: 80%, align(left, it))\
    #if author { text(0.75em)[Me] }
  ])

  let them = (it, author: true) => align(left, [
    #box(..tint(color.purple), radius: 0.25em, width: 80%, align(left, it))\
    #if author { text(0.75em)[Client] }
  ])

  align(center, [
    #me(
      [Good afternoon! I have successfully completed a prototype of the language and I would appreciate feedback on it, if possible?],
      author: false,
    )
    #me([*1 file uploaded*: `<いちご>`])
    #them([Sure, allow me to experiment with the language for some time and I will get back to you.], author: false)
    #them(
      [This is really good! I greatly appreciate the work you've done, however I do believe some improvements can still be made.],
      author: false,
    )
    #them(
      [Firstly, I am afraid the fact that malformed Japanese numeric numerals are interpreted as identifiers, while I would expect an error to be raised.],
      author: false,
    )
    #them(
      [Secondly, I don't think there are enough mapped functions. There is also not any convenient way to accept input from the user, which I believe limits this language from being used in school to its full potential.],
      author: false,
    )
    #them(
      [Lastly, if it's simple enough to implement, could you make printing integers using `プリント` print them in their Japanese form rather than their English form?],
      author: false,
    )
    #them([However, overall, I agree with you that all of the objectives have been met.])
    #me([Thank you very much! I will consider this feedback.])
  ])
}

== Possible Improvements

As my client also helpfully pointed out, there are still various flaws with the language at this stage. The biggest is that it implements a very small subset of QBE instructions, making it barely usable as a programming language. For example, there is no way to allocate stack memory, dereference, take the address of a value, create a variadic function, etc. This could definitely be improved for the future. A simple improvement would be to throw an error when the Japanese numeral is malformed, instead of interpreting the resulting string as an identifier, since this condition is very actionable. I think that implementing a mapped/wrapped version of more functions from the C standard library may be useful, as well as creating a small wrapper, perhaps in C, for accepting user input. An idea I would like to experiment with is to print the Japanese numerals in their Japanese rather than English name, however this may be a more complicated endeavour, due to requiring some way to turn the numeral into a string. Overall, I believe the language is lacking significant important features like importing other files, type equality, function interfaces, etc.

// = #i18n("参考文献", "References")

// == #i18n("Elleのドキュメント", "Elle Documentation")
// - https://github.com/acquitelol/elle/blob/rewrite/DOCS.md

// == #i18n("QBEのドキュメント", "QBE Documentation")
// - https://c9x.me/compile/doc/il.html

// = Why Japanese makes it more interesting
// フー、バル、バズ

// = Formal syntax definition
// フー、バル、バズ

// = The steps to make a compiler
// フー、バル、バズ
// == Tokenization
// フー、バル、バズ
// == Parsing
// フー、バル、バズ
// == Compilation
// フー、バル、バズ

// = Unicode problems
// フー、バル、バズ

// = Mapping Unicode to symbols
// == My options
// == Hexadecimal
// == Punycode
// == Base64
// == Base32
// === RFC 4648
//

// = Calling libc functions
// フー、バル、バズ

// = Basic examples
// フー、バル、バズ

// = Testing
// フー、バル、バズ

// = Limitations
// フー、バル、バズ

// = Final thoughts
// フー、バル、バズ

// = References
// フー、バル、バズ

#bibliography("sources.yaml")
