#ifndef L4UA_PARSER_HPP
#define L4UA_PARSER_HPP

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>
#include <utility>

class node;
using node_ptr = std::shared_ptr<node>;

class context {
};

class token {
public:

private:
  int type_;
  std::size_t begin_;
  std::size_t end_;

  std::string value;

};

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
