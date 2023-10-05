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
//#include "idClass.hpp"
//#include "expressionClass.hpp"
#include "sharedIdentifiers.hpp"


static const char *static_file;
static size_t static_line_no;

static int is_in_equals = 0;


/// monolithic function that takes a delim array and splits terms.
static inline void getline_string_delim(std::vector<std::string>& result,
		std::stringstream& stream, std::string& str, std::vector<std::string> delim_arr) {
	std::string s = "";
	std::string tmp1 = "";

	for (ssize_t j = 0; stream.good(); j++) {
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





/* turns [ a, =, b, +, c ] into:
 * struct {
 * 		a,
 * 		=(struct){
 *			+(struct){
 *				b, c
 *			}
 *		}
 * }
 * where +(struct) has members .lhs and .rhs (types struct pointers)
 * and the anonymous struct has members .id (type string)
 * and .assignment_struct (type struct)
 */


/* copy elision */
# if 0
void tokens_into_lists(std::vector<class idClass>& lists, std::vector<std::string> vec) {
/*	std::map<std::string, enum op> op_arr = {
		{eq_identifier, op::equals},
		{add_identifier, op::add},
		{sub_identifier, op::sub},
		{mul_identifier, op::mul},
		{div_identifier, op::div},
		{mod_identifier, op::mod},
		{rs_identifier, op::rShift},
		{ls_identifier, op::lShift},
		{addeq_identifier, op::addEquals},
		{subeq_identifier, op::subEquals},
		{muleq_identifier, op::mulEquals},
		{diveq_identifier, op::divEquals},
		{modeq_identifier, op::modEquals},
		{rseq_identifier, op::rShiftEquals},
		{lseq_identifier, op::lShiftEquals}
	};*/

	idClass a{"a", "7", nullptr};
	idClass *b1 = new idClass{"a", "6", nullptr};
	idClass *b2 = new idClass{"a", "6", nullptr};
	expressionClass *b = new expressionClass{op::equals, b1, b2};
	a.set_expr(b);
	std::cout << a << "\n";
	lists.push_back(a);
	std::cout << lists.at(0) << "\n";
#if 0
	for (size_t i = 0; i < vec.size(); i++) {
		if (vec[i] == eq_identifier) {
			idClass assign{};
			try {
				std::cout << vec.at(i-1);
				assign.set_str(vec.at(i-1));
			} catch (std::out_of_range const& e) {
				std::cout << "RIGHT HERE" << e.what() << std::endl;
			}
			if (vec.at(i+2) == ";") {
				assign.set_init(vec.at(i+1));
				assign.set_expr(nullptr);
				lists.push_back(assign);
			} else {
				while ((vec.at(i) != ";") && (i < vec.size())) {

					if (vec[i] == eq_identifier ||
					vec[i] == add_identifier ||
					vec[i] == sub_identifier ||
					vec[i] == mul_identifier ||
					vec[i] == div_identifier ||
					vec[i] == mod_identifier ||
					vec[i] == rs_identifier ||
					vec[i] == ls_identifier ||
					vec[i] == addeq_identifier ||
					vec[i] == subeq_identifier ||
					vec[i] == muleq_identifier ||
					vec[i] == diveq_identifier ||
					vec[i] == modeq_identifier ||
					vec[i] == rseq_identifier ||
					vec[i] == lseq_identifier) {
						if (!vec.at(i-1).empty() && !vec.at(i+1).empty()) {
							idClass v1(vec.at(i-1), "", nullptr);
							idClass v2(vec.at(i+1), "", nullptr);

							expressionClass expr(op_arr[vec[i]], v1, v2);
							assign.set_expr(expr.raw());
							lists.push_back(assign);
							break;
						}
					}
				}
			}
		}
	}
#endif
}
#endif


std::vector<std::string> tokenize_assignment_expression(std::string buf,
		std::ifstream& fp, const char *file, size_t lineno) {
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



	for (auto it = result.cbegin(); it != result.cend(); it++) {
		if (it->empty() || *it == " ") {
			result.erase(it);
			it--;
		}
	}

	return result;
}


size_t has_assignment(std::string buf, const char *file, size_t line_no) {
/* identifier is split for the sake of bootstrapping */
	static_file = file;
	static_line_no = line_no;
	size_t idx_of_equals = 0;
	if (buf.empty())
		return buf.length() + 1;

	idx_of_equals = buf.find(eq_identifier);
	if (buf.rfind(eq_identifier) != idx_of_equals) {
		std::string errmsg = "Multiple assignments in one statement unimplemented.";
		parsing_err(ERROR, errmsg.c_str(),
				buf.c_str(), buf.rfind(eq_identifier), static_file, static_line_no);
	}

	if (idx_of_equals != std::string::npos) {
		is_in_equals = 1;
		return idx_of_equals + 1;
	}
	return buf.length() + 1;
}
