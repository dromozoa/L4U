all:: parser

parser.yy: lexer.lua
	./lexer.lua update $@

parser.cxx: parser.yy parser_prologue.hpp parser_epilogue.hpp
	bison -o $@ $<

parser: parser.cxx
	$(CXX) -W -std=c++20 -g -O2 $^ -o $@
