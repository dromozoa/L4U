#ifndef L4UA_PARSER_PROLOGUE_HPP
#define L4UA_PARSER_PROLOGUE_HPP

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>
#include <utility>
#include <vector>

namespace l4ua {
  class node;
  using node_ptr = std::shared_ptr<node>;

  class node {
  public:
    node(const std::string& tag)
      : tag_(tag) {}

    node(const std::string& tag, const std::string& value)
      : tag_(tag), value_(value) {}

    void add(node_ptr node) {
      nodes_.push_back(std::move(node));
    }

  private:
    std::string tag_;
    std::string value_;
    std::vector<node_ptr> nodes_;
  };

  inline node_ptr make_node(const std::string& tag) {
    return std::make_shared<node>(tag);
  }

  inline node_ptr make_node(const std::string& tag, const std::string& value) {
    return std::make_shared<node>(tag, value);
  }

  class context {
  public:
  };

  // T = l4ua::parser::value_type
  // U = l4ua::location
  template <class T, class U>
  int yylex(T* token, U* location, context& ctx) {
    return 1000;
  }
}

#endif
