%require "3.2"
%language "C++"

%define api.value.type variant

%code requires {
  #include "parser.hpp"
}

%token <std::string> TK_NUMBER "number"
%token <std::string> TK_NAME "name"
%token TK_EQUAL TK_EOF

%type <node> chunk stat stat_list expr

%%

chunk
  : stat_list TK_EOF
  ;

stat_list
  : { $$ = std::make_unique<node>("stat_list"); }
  | stat_list stat {
    $1->add($2);
    $$ = $1;
  };

stat
  : TK_NAME TK_EQUAL expr {
    auto node = std::make_unique<node>("Assign");
    node->add(std::make_unique<node>("Name", $1));
    node->add($3);
    $$ = node;
  };

expr
  : TK_NUMBER {
    auto node = std::make_unique<node>("Number", $1);
    $$ = node;
  };

%%

int main(int ac, char* av) {
  return 0;
}
