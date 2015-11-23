#lang scribble/manual

@(require scribble/bnf)

@(define (codeblock/verbatim . pre-content)
   (nested #:style 'code-inset (apply verbatim pre-content)))

@title[#:version ""]{Tulip Formal Syntax}

This provides a formal syntax for Tulip written in an extended BNF.

@section{Datums and Operators}

@BNF[(list @nonterm{identifier}
           @BNF-seq[@nonterm{identifier start} @kleenestar[@nonterm{identifier body}]])
     (list @nonterm{identifier start} @nonterm{letter})
     (list @nonterm{identifier body} @BNF-alt[@nonterm{letter} @nonterm{digit} @litchar{-}])

     (list @nonterm{tag word} @BNF-seq[@litchar{.} @nonterm{identifier}])
     (list @nonterm{flag word} @BNF-seq[@litchar{-} @nonterm{identifier}])

     (list @nonterm{number}
           @BNF-seq[@kleeneplus[@nonterm{digit}] @optional[@litchar{.}]]
           @BNF-seq[@kleenestar[@nonterm{digit}] @litchar{.} @kleeneplus[@nonterm{digit}]])
     
     (list @nonterm{letter}
           @BNF-alt[@litchar{a} @litchar{b} @litchar{c} BNF-etc @litchar{z}]
           @BNF-alt[@litchar{A} @litchar{B} @litchar{C} BNF-etc @litchar{Z}])
     (list @nonterm{digit}
           @BNF-alt[@litchar{0} @litchar{1} @litchar{2} @litchar{3} @litchar{4}
                    @litchar{5} @litchar{6} @litchar{7} @litchar{8} @litchar{9}])

     (list @nonterm{sequence delimiter} @BNF-alt[@litchar{;} "newline"])]

@section{Expressions}

@BNF[(list @nonterm{expression}
           @nonterm{group}
           @nonterm{block}
           @nonterm{chain}
           @nonterm{application}
           @nonterm{identifier}
           @nonterm{tag word}
           @nonterm{flag pair}
           @nonterm{lambda}
           @nonterm{block lambda}
           @litchar{$})
     (list @nonterm{group}
           @BNF-seq[@litchar{(} @nonterm{expression} @litchar{)}])
     (list @nonterm{block}
           @BNF-seq[@litchar["{"] @nonterm{expression}
                    @kleenestar[@BNF-group[@nonterm{sequence delimiter} @nonterm{expression}]]
                    @litchar["}"]])
     (list @nonterm{chain}
           @BNF-seq[@nonterm{expression} @litchar{>} @nonterm{expression}])
     (list @nonterm{application}
           @kleeneplus[@nonterm{expression}]
           @BNF-seq[@nonterm{expression} @litchar{!}])
     (list @nonterm{flag pair}
           @BNF-seq[@nonterm{flag word} @litchar{:} @nonterm{expression}])]

Note that @litchar{$} is only allowed as an @nonterm{expression} while parsing an
@nonterm{auto lambda}.

@subsection[#:tag "lambdas"]{Lambdas}

@BNF[(list @nonterm{lambda} @BNF-seq[@litchar{[} @nonterm{lambda body} @litchar{]}])
     (list @nonterm{block lambda} @BNF-seq[@litchar["{"] @nonterm{lambda body} @litchar["}"]])
     (list @nonterm{lambda body} @BNF-alt[@nonterm{full lambda} @nonterm{auto lambda}])
     (list @nonterm{full lambda}
           @BNF-seq[@nonterm{lambda clause}
                    @kleenestar[@BNF-group[@nonterm{sequence delimiter} @nonterm{lambda clause}]]])
     (list @nonterm{lambda clause}
           @BNF-seq[@nonterm{lambda formals} @litchar{=>} @nonterm{expression}])
     (list @nonterm{lambda formals}
           @kleeneplus[@nonterm{pattern}]
           @litchar{!})
     (list @nonterm{auto lambda} @nonterm{expression})]

@BNF[(list @nonterm{pattern}
           @nonterm{grouped pattern}
           @nonterm{conjunct pattern}
           @nonterm{condition pattern}
           @nonterm{tag pattern}
           @nonterm{identifier}
           @nonterm{number}
           @litchar{_})
     (list @nonterm{grouped pattern}
           @BNF-seq[@litchar{(} @nonterm{pattern} @litchar{)}])
     (list @nonterm{conjunct pattern}
           @BNF-seq[@nonterm{pattern} @litchar{:} @nonterm{pattern}])
     (list @nonterm{condition pattern}
           @BNF-seq[@nonterm{pattern} @litchar{?} @nonterm{expression}])
     (list @nonterm{tag pattern}
           @BNF-seq[@nonterm{tag word} @kleenestar[@nonterm{pattern}]])]

The above grammar is slightly ambiguous when applied to the following syntax:

@codeblock/verbatim{[ .foo bar baz => ... ]}

Specifically, either of the following forms would be reasonable interpretations:

@codeblock/verbatim{[ (.foo) bar baz => ... ]
                    [ (.foo bar baz) => ... ]}

To disambiguate, a special rule is considered when parsing the pattern for the first argument of a
lambda. If the pattern is a @nonterm{tag pattern}, then the lambda is parsed as accepting a single
argument, the tag. If the pattern is anything else, then @italic{all} patterns at root level of the
lambda formals are treated as patterns for individual arguments.

@codeblock/verbatim{[ .foo bar baz => ... ]   # parses as [ (.foo bar baz) => ... ]
                    [ (.foo) bar baz => ... ] # parses as [ (.foo) bar baz => ... ]
                    [ foo .bar baz => ... ]   # parses as [ foo (.bar) baz => ... ]}

@section{Definitions}

@BNF[(list @nonterm{definition}
           @BNF-seq[@nonterm{declaration} @litchar{=} @nonterm{expression}])
     (list @nonterm{declaration}
           @nonterm{binding declaration}
           @nonterm{function declaration})
     (list @nonterm{binding declaration}
           @nonterm{identifier})
     (list @nonterm{function declaration}
           @BNF-seq[@nonterm{identifier} @nonterm{lambda formals}])]

Function definitions do not use the custom pattern parsing rule described in @secref{lambdas}, so
patterns are always interpreted as separate arguments when possible.

@codeblock/verbatim{foo .bar baz = ... # parses like [ (.bar) baz => ... ]}

@section{Whole Programs}

@BNF[(list @nonterm{program}
           @BNF-seq[@nonterm{top-level form}
                    @kleenestar[@BNF-group[@nonterm{sequence delimiter} @nonterm{top-level form}]]])
     (list @nonterm{top-level form}
           @nonterm{expression}
           @nonterm{definition})]
