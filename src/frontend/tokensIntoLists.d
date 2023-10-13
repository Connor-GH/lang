import std.stdio : writeln;
import std.conv : to;
import std.string : toStringz;
import core.memory : GC;
import core.stdc.stdlib : exit;
import core.stdcpp.string : basic_string, char_traits;
import idClass : idClass;
import expressionClass : expressionClass, op;
import parsingError;
import logWriteln : logWriteln, logLevel;

/// Returns the index of string in array, returns -1 if not found
@nogc @safe
static long contains(string[] v, string s) {
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



	scope idClass[] lists;
	foreach (i, str; vec) {
		if (str == "=") {
			if (i > 0) {
				idClass temp = new idClass();
				temp.set_str(vec[i-1]);

				long pos = 0;
				op operation = op.uninitialized;

				if (vec.contains("+") != -1) {
					pos = vec.contains("+");
					operation = op.add;
				} else if (vec.contains("-") != -1) {
					pos = vec.contains("-");
					operation = op.sub;
				} else if (vec.contains("*") != -1) {
					pos = vec.contains("*");
					operation = op.mul;
				} else if (vec.contains("/") != -1) {
					pos = vec.contains("/");
					operation = op.div;
				} else if (vec.contains("%") != -1) {
					pos = vec.contains("%");
					operation = op.mod;
				} else if (vec.contains("<<") != -1) {
					pos = vec.contains("<<");
					operation = op.lShift;
				} else if (vec.contains(">>") != -1) {
					pos = vec.contains(">>");
					operation = op.rShift;
				} else {
					// assume a normal assignment
					temp.set_init(vec[i+1]);
					lists ~= temp;
				break;
				}
				idClass v1 = new idClass();
				idClass v2 = new idClass();
				if ((vec[pos-1] != "=") && (vec[pos+1] != "=")) {
					v1.set_str(vec[pos-1]);
					v2.set_str(vec[pos+1]);
				} else {
					// *= or += or /= ...
					if (vec[pos+1] == "=") {
						temp.set_str(vec[pos-1]);
						v1.set_str(vec[pos-1]);
						if ((pos+2) > size) {
							logWriteln(logLevel.fatalError, "Statement malformed.");
							exit(1);
						}
						v2.set_str(vec[pos+2]);
					}
				}
				expressionClass expr = new expressionClass(operation, v1, v2);
				temp.set_expr(expr);
				lists ~= temp;

			} else {
				parsing_err(ERROR, toStringz("Nonsensical statement.\n"),
						get_buffer(), i);
			}

		}
	}
	foreach (id; lists) {
		logWriteln(logLevel.error, id);
		id.destroy();
	}
}
