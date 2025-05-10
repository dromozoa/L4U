%require "3.2"
%language "C++"

// %define api.prefix {l4ua_}
%define api.namespace {l4ua}
%define api.value.type variant

%param {context& ctx}
%locations

%code requires {
  #include "parser_prologue.hpp"
}

// BEGIN TOKENS
%token TOKEN_EOF 1000
%token <std::string> INTEGER 1001
%token EQ 1002
%token LP 1003
%token RP 1004
%token END 1005
%token FUNCTION 1006
%token LOCAL 1007
%token <std::string> NAME 1008
// END TOKENS

%type <node_ptr> chunk block stat funcbody parlist expr

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
    $$->add(make_node("Name", $2, @2));
    $$->add($3);
  }
  | LOCAL NAME EQ expr {
    $$ = make_node("local", @$);
    $$->add(make_node("Name", $2, @2));
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

expr
  : INTEGER {
    $$ = make_node("integer", $1, @1);
  };

%%

#include "parser_epilogue.hpp"
