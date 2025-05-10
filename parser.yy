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
%token LOCAL 1003
%token <std::string> NAME 1004
// END TOKENS

%type <node_ptr> chunk stat stat_list expr

%%

chunk
  : stat_list TOKEN_EOF {
    $$ = $1;
  };

stat_list
  : {
    $$ = make_node("stat_list");
  }
  | stat_list stat {
    $1->add($2);
    $$ = $1;
  };

stat
  : LOCAL NAME EQ expr {
    $$ = make_node("local");
    $$->add(make_node("Name", $2));
    $$->add($4);
  };

expr
  : INTEGER {
    $$ = make_node("integer", $1);
  };

%%

#include "parser_epilogue.hpp"
