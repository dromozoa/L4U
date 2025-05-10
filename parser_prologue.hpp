#ifndef L4UA_PARSER_PROLOGUE_HPP
#define L4UA_PARSER_PROLOGUE_HPP

#include <cerrno>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <exception>
#include <fstream>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <system_error>
#include <utility>
#include <vector>

namespace l4ua {
  class node;
  using node_ptr = std::shared_ptr<node>;

  class node {
  public:
    explicit node(const std::string& tag)
      : tag_(tag) {}

    node(const std::string& tag, const std::string& value)
      : tag_(tag), value_(value) {}

    void add(node_ptr node) {
      nodes_.push_back(std::move(node));
    }

    void print(std::ostream& out) {
      out << tag_ << "\n";
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

  struct token {
    std::int32_t token_id;
    std::int32_t capture;
    std::string value;
    std::int32_t begin_line;
    std::int32_t begin_column;
    std::int32_t end_line;
    std::int32_t end_column;
  };

  class context {
  public:
    context(const char* input_file, const char* output_file)
      : token_index_(), output_file_(output_file) { load(input_file); }

    const token* next() {
      if (token_index_ < tokens_.size()) {
        return &tokens_[token_index_++];
      } else {
        return nullptr;
      }
    }

    void print(node_ptr node) {
      std::ofstream out(output_file_, std::ios::out | std::ios::binary);
      out.exceptions(std::ios::failbit);
      node->print(out);
    }

  private:
    std::vector<token> tokens_;
    std::size_t token_index_;
    std::string output_file_;

    void load(const char* file) {
      using file_handle_t = std::unique_ptr<FILE, decltype(&std::fclose)>;

      if (file_handle_t handle = file_handle_t(fopen(file, "rb"), &std::fclose)) {
        std::vector<char> buffer;
        while (!std::feof(handle.get())) {
          token tk = {};

          if (std::fread(&tk.token_id, sizeof(tk.token_id), 1, handle.get()) != 1) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }

          if (std::fread(&tk.capture, sizeof(tk.capture), 1, handle.get()) != 1) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }

          std::uint32_t size = 0;
          if (std::fread(&size, sizeof(size), 1, handle.get()) != 1) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }
          buffer.resize(size);
          if (std::fread(buffer.data(), 1, size, handle.get()) != size) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }
          tk.value = std::string(buffer.data(), buffer.size());

          if (std::fread(&tk.begin_line, sizeof(tk.begin_line), 1, handle.get()) != 1) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }
          if (std::fread(&tk.begin_column, sizeof(tk.begin_column), 1, handle.get()) != 1) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }
          if (std::fread(&tk.end_line, sizeof(tk.end_line), 1, handle.get()) != 1) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }
          if (std::fread(&tk.end_column, sizeof(tk.end_column), 1, handle.get()) != 1) {
            throw std::system_error(errno, std::generic_category(), "cannot fread");
          }

          if (ferror(handle.get())) {
            throw std::system_error(errno, std::generic_category(), "ferror");
          }

          std::cerr
            << tk.token_id << "\t"
            << tk.capture << "\t"
            << tk.value << "\t"
            << tk.begin_line << "\t" << tk.begin_column << "\t"
            << tk.end_line << "\t" << tk.end_column << "\n";

          tokens_.push_back(tk);
          if (tk.token_id == 1000) { // TOKEN_EOF
            break;
          }
        }
      } else {
        throw std::system_error(errno, std::generic_category(), "cannot fopen");
      }
    }
  };

  // T = l4ua::parser::value_type
  // U = l4ua::location
  template <class T, class U>
  int yylex(T* value, U* location, context& ctx) {
    if (const token* tk = ctx.next()) {
      if (tk->capture) {
        value->template as<std::string>() = tk->value;
      }

      location->begin.line = tk->begin_line;
      location->begin.column = tk->begin_column;
      location->end.line = tk->end_line;
      location->end.column = tk->end_column;

      return tk->token_id;
    } else {
      return 0; // YYEOF
    }
  }
}

#endif
