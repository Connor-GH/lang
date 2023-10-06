#ifndef CLASSES_HPP
#define CLASSES_HPP

#include <vector>
#include <string>
size_t has_assignment(std::string buf, const char *file, size_t line_no);
std::vector<std::string> tokenize_assignment_expression(std::string buf);

#endif
