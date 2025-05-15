%require "3.2"
%language "C++"

%define api.namespace {L4U}
%define api.value.type variant

%param {context& ctx}
%locations

%code requires {
  #include "parser_prologue.hpp"
}

// BEGIN TOKENS
%token TOKEN_EOF 1000
%token <std::string> INTEGER 1001
%token ADD 1002
%token SUB 1003
%token MUL 1004
%token DIV 1005
%token EQ 1006
%token LP 1007
%token RP 1008
%token END 1009
%token FUNCTION 1010
%token LOCAL 1011
%token <std::string> NAME 1012
// END TOKENS

%type <node_ptr> chunk block stat funcbody parlist exp

%left ADD SUB
%left MUL DIV

%%

chunk
  : block TOKEN_EOF {
    $$ = $1;
    ctx.print($$);
  };

block
  : {
    $$ = make_node("block", @$);
  }
  | block stat {
    $1->add($2);
    $$ = $1;
  };

stat
  : FUNCTION NAME funcbody {
    $$ = make_node("function", @$);
    $$->add(make_node("name", $2, @2));
    $$->add($3);
  }
  | LOCAL NAME EQ exp {
    $$ = make_node("local", @$);
    $$->add(make_node("name", $2, @2));
    $$->add($4);
  };

funcbody
  : LP parlist RP block END {
    $$ = make_node("funcbody", @$);
    $$->add($2);
    $$->add($4);
  };

parlist
  : {
    $$ = make_node("parlist", @$);
  };

exp
  : INTEGER {
    $$ = make_node("integer", $1, @1);
  }
  | NAME {
    $$ = make_node("var", $1, @1);
  }
  | exp ADD exp {
    $$ = make_node("add", @$);
    $$->add($1);
    $$->add($3);
  }
  | exp MUL exp {
    $$ = make_node("mul", @$);
    $$->add($1);
    $$->add($3);
  }
  ;

%%

#include "parser_epilogue.hpp"
