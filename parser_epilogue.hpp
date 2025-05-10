#ifndef L4UA_PARSER_EPILOGUE_HPP
#define L4UA_PARSER_EPILOGUE_HPP

namespace l4ua {
  void parser::error(const location& location, const std::string& message) {
    std::ostringstream out;
    out << "parser error at " << location << ": " << message;
    throw std::runtime_error(out.str());
  }
}

// input_file output_file
int main(int ac, char* av[]) {
  using namespace l4ua;

  if (ac < 3) {
    std::cerr << av[0] << " input_file output_file\n";
    return 1;
  }

  try {
    context ctx(av[1]);
    return 0;
  } catch (const std::exception& e) {
    std::cerr << e.what() << "\n";
  } catch (...) {
    std::cerr << "unknown error\n";
  }
  return 1;
}

#endif
