import std.stdio;
import std.conv;
import core.memory : GC;
import core.stdc.stdlib;
import core.stdcpp.string;
import idClass : idClass;
import expressionClass : expressionClass, op;
import logWriteln : logWriteln, logLevel;

/// Returns the index of string in array, returns -1 if not found
static auto contains(string[] v, string s) {
	foreach (i, str; v) {
		if (str == s)
			return i;
	}
	return -1;
}
alias stdcpp_string = basic_string!(char, char_traits!char);
extern (C++) void tokens_into_lists(stdcpp_string *cpp_vec, size_t size) {
	// convert vector of std::string from C++ into Dlang string array
	string[] vec;
	vec.length = size;
	for (size_t i = 0; i < size; i++) {
		// convert from std::string -> char[] -> string
		vec[i] = to!(string)(cpp_vec[i].as_array());
	}
	foreach (str; vec) {
		logWriteln(logLevel.warning, str);
	}



	idClass[] lists;
	foreach (i, str; vec) {
		if (str == "=") {
			if (i > 0) {
				idClass temp = new idClass();
				temp.set_str(vec[i-1]);
				if (vec.contains("+") != -1) {
					auto pos = vec.contains("+");
					// not "= +" or "+ ="
					if ((vec[pos-1] != "=") || (vec[pos+1] != "=")) {
						idClass v1 = new idClass();
						v1.set_str(vec[pos-1]);
						idClass v2 = new idClass();
						v2.set_str(vec[pos+1]);
						expressionClass expr = new expressionClass(op.add, v1, v2);
						temp.set_expr(expr);
						lists ~= temp;
					}
				} else if (vec.contains("-") != -1) {
					auto pos = vec.contains("-");
				} else if (vec.contains("*") != -1) {
					auto pos = vec.contains("*");
				} else if (vec.contains("/") != -1) {
					auto pos = vec.contains("/");
				} else if (vec.contains("%") != -1) {
					auto pos = vec.contains("%");
				} else if (vec.contains("<<") != -1) {
					auto pos = vec.contains("<<");
				} else if (vec.contains(">>") != -1) {
					auto pos = vec.contains(">>");
				} else {
					// assume a normal assignment
					temp.set_init(vec[i+1]);
					lists ~= temp;
				}
			}
		}
	}
	foreach (id; lists)
		logWriteln(logLevel.error, id);

	GC.collect();
}
