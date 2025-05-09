all:: parser.cxx

parser.yy: lexer.lua
	./lexer.lua update $@

parser.cxx: parser.yy parser.hpp
	bison -o $@ $<
