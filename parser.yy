%require "3.2"
%language "C++"

%define api.prefix {l4ua_}
%define api.value.type variant

%locations
%param {context& ctx}

%code requires {
  #include "parser.hpp"
}

%token <std::string> Integer Name
%token Equal EOF_TOKEN

%type <node> chunk stat stat_list expr

%%

chunk
  : stat_list EOF_TOKEN
  ;

stat_list
  : { $$ = std::make_unique<node>("stat_list"); }
  | stat_list stat {
    $1->add($2);
    $$ = $1;
  };

stat
  : Name Equal expr {
    auto node = std::make_unique<node>("Assign");
    node->add(std::make_unique<node>("Name", $1));
    node->add($3);
    $$ = node;
  };

expr
  : Integer {
    auto node = std::make_unique<node>("integer", $1);
    $$ = node;
  };

%%

int main(int ac, char* av) {
  return 0;
}
