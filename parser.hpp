#ifndef L4UA_PARSER_HPP
#define L4UA_PARSER_HPP

#include <memory>
#include <string>
#include <utility>

class node;
using node_ptr = std::unique_ptr<node>;

class node {
public:
  node(const std::string& tag)
    : tag_(tag) {}

  node(const std::string& tag, const std::string& value)
    : tag_(tag), value_(value) {}

  void add(node_ptr&& node) {
    nodes_.push_back(std::move(node));
  }

private:
  std::string tag_;
  std::string value_;
  std::vector<node_ptr> nodes_;
};

#endif
