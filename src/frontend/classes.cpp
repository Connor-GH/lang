#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include <memory>
#include <map>

#include <cctype>
#include <cstdlib>

#include "parsing_error.h"
#include "classes.hpp"
#include "sharedIdentifiers.hpp"



static int is_in_equals = 0;


/// monolithic function that takes a delim array and splits terms.
static inline void getline_string_delim(std::vector<std::string>& result,
		std::stringstream& stream, std::string& str, std::vector<std::string> delim_arr) {
	std::string s = "";
	std::string tmp1 = "";

	while (stream.good()) {
		size_t k = 0;
		for (std::string delim : delim_arr) {
			while (k < delim.size()) {
				if (delim.find(static_cast<char>(stream.peek())) != std::string::npos) {
					tmp1 += static_cast<char>(stream.get());
					k++;
					continue;
				} else {
					break;
				}
			}
			if (k == delim.size()) {
				str = s;
				result.push_back(s);
				s.clear();
				result.push_back(tmp1);
				tmp1.clear();
			}
		}
		if (stream.eof()) {
			str = s;
			result.push_back(s);
			s.clear();
			result.push_back(tmp1);
			tmp1.clear();
		} else {
			s += tmp1;
			tmp1.clear();
			if (stream.good())
				s += static_cast<char>(stream.get());
		}
	}
}





std::vector<std::string> tokenize_assignment_expression(std::string buf) {
	std::vector<std::string> result;
	std::stringstream ss(buf);
	std::string tmp;

	std::vector<std::string> delim_arr = {
		eq_identifier,
		add_identifier,
		sub_identifier,
        mul_identifier,
        div_identifier,
        addeq_identifier,
        subeq_identifier,
        muleq_identifier,
        diveq_identifier,
		";",
	 	" "
	};
	/* tokenize based on =+*-/; */
	getline_string_delim(result, ss, tmp, delim_arr);


	for (std::string& str : result) {
		while (str.find(" ") != std::string::npos) {
			str.erase(str.find(" "), str.find(" ")+1);
		}
	}

	for (auto it = result.cbegin(); it != result.cend(); it++) {
		if (it->empty() || *it == " ") {
			result.erase(it);
			it--;
		}
	}

	return result;
}


size_t has_assignment(std::string buf) {
/* identifier is split for the sake of bootstrapping */
	size_t idx_of_equals = 0;
	if (buf.empty())
		return buf.length() + 1;

	idx_of_equals = buf.find(eq_identifier);
	if (buf.rfind(eq_identifier) != idx_of_equals) {
		std::string errmsg = "Multiple assignments in one statement unimplemented.";
		parsing_err(ERROR, errmsg.c_str(),
				buf.c_str(), buf.rfind(eq_identifier));
	}

	if (idx_of_equals != std::string::npos) {
		is_in_equals = 1;
		return idx_of_equals + 1;
	}
	return buf.length() + 1;
}
