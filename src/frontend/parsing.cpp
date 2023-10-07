#include <string>
#include <fstream>
#include <iostream>
#include <vector>

#include <cstdlib>
#include <cerrno>
#include <cstring>

#include "parsing_error.h"
#include "classes.hpp"

static int is_in_comment = 0;
static size_t line_no = 0;

void tokens_into_lists(std::string *vec, size_t size);

static constexpr const char *begin_comment = "/" "*";
static constexpr const char *end_comment = "*" "/";

static std::string
remove_portion_of_buffer_and_merge(std::string initbuf, size_t start,
								   size_t end)
{
	std::string start_portion, end_portion;

	if ((initbuf.length() < start) || (initbuf.length() < end))
		return initbuf;
	if ((start == 0) && (end == initbuf.length())) {
		initbuf.clear();
		return initbuf;
	}

	start_portion = initbuf.substr(0, (initbuf.find(begin_comment) != std::string::npos) ? start - 1 : start);

	if (end < initbuf.length()-1)
		end_portion = initbuf.substr(end + 1, initbuf.length() - 1);
	initbuf.clear();
	initbuf = start_portion + end_portion;

	return initbuf;
}

static size_t
has_end_comment(std::string buf)
{
	size_t idx_of_end_comment = 0;
	if (buf.empty())
		return buf.length()+1;

	idx_of_end_comment = buf.find(end_comment);
	if (buf.rfind(end_comment) != idx_of_end_comment)
		parsing_err(ERROR, "Nested comments are not supported.", buf.c_str(),
					buf.rfind(end_comment));
	if (idx_of_end_comment != std::string::npos) {
		is_in_comment = 0;
		return idx_of_end_comment + 1;
	}
	return buf.length()+1;
}
static size_t
has_begin_comment(std::string buf)
{
	size_t idx_of_begin_comment = 0;
	if (buf.empty())
		return buf.length()+1;

	idx_of_begin_comment = buf.find(begin_comment);
	if (buf.rfind(begin_comment) != idx_of_begin_comment)
		parsing_err(ERROR, "Nested comments are not supported.", buf.c_str(),
					buf.rfind(begin_comment));
	if (idx_of_begin_comment != std::string::npos) {
		is_in_comment = 1;
		return idx_of_begin_comment + 1;
	}
	return buf.length()+1;
}


extern "C++" void
enter_block_and_parse(char const *file)
{
	std::ifstream fp;
	size_t start = 0, end = 0;
	std::string initbuf;
	std::string tmp_buf;
	int error_num;
	if (strcmp(file, "stdin") != 0) {
		set_file(file);
		fp.open(file);
		if (!fp.is_open()) {
			error_num = errno;
			std::cerr << "failed to open " << file << ": "
				<< strerror(error_num) << std::endl;
			std::exit(EXIT_FAILURE);
		}
	} else {
		set_file("stdin");
	}
	while (std::getline((strcmp(file, "stdin") == 0) ? std::cin : fp, initbuf)) {
		line_no++;
		set_line_number(line_no);
		set_buffer(initbuf.c_str());
		start = has_begin_comment(initbuf);
		end = has_end_comment(initbuf);

		/* parse comments */
		if (start < initbuf.length() && end < initbuf.length()) {
			initbuf =
				remove_portion_of_buffer_and_merge(initbuf, start, end);
		} else if (start < initbuf.length() && !(end < initbuf.length())) {
			initbuf = remove_portion_of_buffer_and_merge(
				initbuf, start, initbuf.length() - 1);
		} else if (!(start < initbuf.length()) && end < initbuf.length()) {
			initbuf = remove_portion_of_buffer_and_merge(initbuf, 0,
					end);
		} else if (is_in_comment) {
			initbuf = remove_portion_of_buffer_and_merge(
			initbuf, 0, initbuf.length() - 1);
		}


		// raw line without any parsing
		if (!initbuf.empty())
			std::cout << initbuf << std::endl;


		if (has_assignment(initbuf, file, line_no) < initbuf.length()) {
			std::vector<std::string> vec = tokenize_assignment_expression(initbuf);
			// line tokenized
			for (std::string s : vec)
				std::cout << s << ", ";
			std::cout << "\n";
			// D binding info
			size_t size = vec.size();
			// allocate memory for binding into D
			std::string *str = new std::string[size];
			for (size_t i = 0; i < size; i++) {
				str[i] = vec[i];
			}
			// this prints each token on a separate line and
			// also the classes that are built
			tokens_into_lists(str, size);
			delete[] str;
		}


	}
	if (strcmp(file, "stdin") != 0) {
		fp.close();
	}
}
