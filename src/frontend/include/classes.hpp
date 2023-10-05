#ifndef CLASSES_HPP
#define CLASSES_HPP

#include <vector>
#include <string>
//#include "../idClass.hpp"
/* identifier is split for the sake of bootstrapping */

size_t has_assignment(std::string buf, const char *file, size_t line_no);
std::vector<std::string> tokenize_assignment_expression(std::string buf, std::ifstream& fp, const char *file, size_t lineno);
//void tokens_into_lists(std::vector<class idClass>& lists, std::vector<std::string> vec);

#endif
