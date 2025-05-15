#! /bin/sh -e

here=`dirname "$0"`
here=`(cd "$here" && pwd)`

file=$1
case X$file in
  X)
    echo "$0 file"
    exit 1;;
esac

name=`expr "X$file" : 'X\(.*\)\.[^.]*$'`
"$here/lexer.lua" lexer "$name.lex" <"$file"
"$here/parser" "$name.lex" "$name.ast"
"$here/generator.lua" <"$name.ast"
