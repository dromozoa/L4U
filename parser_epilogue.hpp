#ifndef L4UA_PARSER_EPILOGUE_HPP
#define L4UA_PARSER_EPILOGUE_HPP

namespace l4ua {
  void node::set_location(const location& location) {
    begin_line_ = location.begin.line;
    begin_column_ = location.begin.column;
    end_line_ = location.end.line;
    end_column_ = location.end.column;
  }

  void parser::error(const location& location, const std::string& message) {
    std::ostringstream out;
    out << "parser error at " << location << ": " << message;
    throw std::runtime_error(out.str());
  }
}

// input_file output_file
int main(int ac, char* av[]) {
  if (ac < 3) {
    std::cerr << av[0] << " input_file output_file\n";
    return 1;
  }

  try {
    l4ua::context context(av[1], av[2]);
    l4ua::parser parser(context);
    parser.parse();

    return 0;
  } catch (const std::exception& e) {
    std::cerr << e.what() << "\n";
  } catch (...) {
    std::cerr << "unknown error\n";
  }
  return 1;
}

#endif
