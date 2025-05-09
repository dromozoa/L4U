%require "3.2"
%language "C++"

%define api.prefix {l4ua_}
%define api.value.type variant

%param {context& ctx}

%code requires {
  #include "parser.hpp"
}

// BEGIN TOKENS
%token EOF 1000
%token <std::string> INTEGER 1001
%token EQ 1002
%token <std::string> NAME 1003
// END TOKENS

%type <node_ptr> chunk stat stat_list expr

%%

chunk
  : stat_list EOF {
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
  : NAME EQ expr {
    $$ = make_node("assign");
    $$->add(make_node("Name", $1));
    $$->add($3);
  };

expr
  : INTEGER {
    $$ = make_node("integer", $1);
  };

%%

int main(int ac, char* av) {
  return 0;
}
