#include <sstream>
#include <string>
#include <vector>

#include <cctype>

#include "classes.hpp"
#include "parsing_error.h"
#include "sharedIdentifiers.hpp"

namespace
{
class my_stringstream {
private:
	const std::string str;
	size_t current_idx;
	bool is_eof;

public:
	my_stringstream(const std::string str_) : str(str_), 
		current_idx(0), is_eof(false) {}

	char peek() {
		if ((current_idx+1) <= (str.length()-1)) {
			return str[current_idx+1];
		} else {
			is_eof = true;
			return 0;
		}
	}
	char get() {
		current_idx++;
		return str[current_idx-1];
	}
	bool eof() {
		return is_eof;
	}
	bool good() {
		return this->eof() == false;
	}

	~my_stringstream() {}
};


/// monolithic function that takes a delim array and splits terms.
inline void
getline_string_delim(std::vector<std::string> &result,
					 my_stringstream &stream, std::string &str,
					 const std::vector<std::string> &delim_arr)
{
	std::string s = "";
	std::string tmp1 = "";

	while (stream.good()) {
		size_t k = 0;
		for (const std::string &delim : delim_arr) {
			while (k < delim.size()) {
				if (delim.find(stream.peek()) !=
					std::string::npos) {
					tmp1 += stream.get();
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
				k--;
			}
		}
		if (stream.eof()) {
			str = s;
			result.push_back(s);
			s.clear();
			result.push_back(tmp1);
			tmp1.clear();
			k--;
		} else {
			s += tmp1;
			tmp1.clear();
			if (stream.good()) {
				s += stream.get();
			}
		}
	}
}

} // anonymous namespace

auto
tokenize_assignment_expression(const std::string &buf)
	-> std::vector<std::string>
{
	std::vector<std::string> result;
	my_stringstream ss(buf);
	std::string tmp;

	const std::vector<std::string> delim_arr = { " ",
												 eq_identifier,
												 add_identifier,
												 sub_identifier,
												 mul_identifier,
												 div_identifier,
												 mod_identifier,
												 rs_identifier,
												 ls_identifier,
												 addeq_identifier,
												 subeq_identifier,
												 muleq_identifier,
												 diveq_identifier,
												 modeq_identifier,
												 rseq_identifier,
												 lseq_identifier,
												 right_paren,
												 left_paren,
												 right_sq_brace,
												 left_sq_brace,
												 right_curly_brace,
												 left_curly_brace,
												 ";" };
	/* tokenize based on =+*-/; */
	getline_string_delim(result, ss, tmp, delim_arr);

	for (std::string &str : result) {
		while (str.find(' ') != std::string::npos) {
			str.erase(str.find(' '), str.find(' ') + 1);
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
