import std.stdio : writeln;
import std.conv : to;
import std.string : toStringz, fromStringz, indexOf;
import core.memory : GC;
import core.stdc.stdlib : exit;
import core.stdcpp.string : basic_string, char_traits;
import idClass : idClass;
import expressionClass : expressionClass, op, toOperator_;
import parsingError;
import logWriteln : logWriteln, logLevel;
import ir;

/// Returns the index of string in array, returns -1 if not found
@nogc @safe static long contains(string[] v, string s)
{
	foreach (i, str; v) {
		if (str == s)
			return i;
	}
	return -1;
}

static long has_operator_(string[] vec)
{
	long pos = 0;
	if (vec.contains("+") != -1) {
		pos = vec.contains("+");
	} else if (vec.contains("-") != -1) {
		pos = vec.contains("-");
	} else if (vec.contains("*") != -1) {
		pos = vec.contains("*");
	} else if (vec.contains("/") != -1) {
		pos = vec.contains("/");
	} else if (vec.contains("%") != -1) {
		pos = vec.contains("%");
	} else if (vec.contains("<<") != -1) {
		pos = vec.contains("<<");
	} else if (vec.contains(">>") != -1) {
		pos = vec.contains(">>");
	}
	return pos;
}

static idClass handle_multi_expression(string[] vec)
{
	// Arithmetic grouping symbols exist and they are in the proper order
	if ((vec.contains("(") != -1) && (vec.contains(")") != -1) &&
			(vec.contains("(") < vec.contains(")"))) {
		op operation = op.uninitialized;
		long pos = 0;
		string[] paren_vec = vec[vec.contains("(") .. vec.contains(")")];

		if (paren_vec.contains("+") != -1) {
			pos = paren_vec.contains("+");
			operation = op.add;
		} else if (paren_vec.contains("-") != -1) {
			pos = paren_vec.contains("-");
			operation = op.sub;
		} else if (paren_vec.contains("*") != -1) {
			pos = paren_vec.contains("*");
			operation = op.mul;
		} else if (paren_vec.contains("/") != -1) {
			pos = paren_vec.contains("/");
			operation = op.div;
		} else if (paren_vec.contains("%") != -1) {
			pos = paren_vec.contains("%");
			operation = op.mod;
		} else if (paren_vec.contains("<<") != -1) {
			pos = paren_vec.contains("<<");
			operation = op.lShift;
		} else if (paren_vec.contains(">>") != -1) {
			pos = paren_vec.contains(">>");
			operation = op.rShift;
		}
		if (pos == 0)
			return new idClass();
		if (((pos - 1) == paren_vec.contains("(")) ||
				((pos + 1) == paren_vec.contains(")"))) {
			parsing_err(
					ERROR,
					toStringz(
					"Identifier or number expected " ~
					"before arithmetic operator"),
					get_buffer(),
					get_buffer().fromStringz.indexOf(paren_vec[pos]));
		}

		// left and right of the expression
		// foo = (bar + baz);
		//         ^     ^
		//         a     b
		idClass a = new idClass();
		a.set_str(paren_vec[pos - 1]);
		idClass b = new idClass();
		b.set_str(paren_vec[pos + 1]);
		expressionClass expr = new expressionClass(operation, a, b);

		idClass id = new idClass("__unnamed", "", expr);

		idClass ref_var = handle_multi_expression(
				vec[0 .. (vec.contains("("))] ~ vec[(vec.contains(")") + 1) .. $]);

		expressionClass expr2 = new expressionClass(
				(vec.has_operator_() != -1)
				? vec[vec.has_operator_()].toOperator_ : op.uninitialized,
				id, ref_var);

		return new idClass(vec[vec.contains("=") - 1], "", expr2);
	} else {
		long pos = 0;
		pos = vec.has_operator_();

		if (pos > 0) {
			// = + 7
			if (vec[pos - 1] == "=") {
				if (vec[pos + 1] != ";") {
					expressionClass tmp = new expressionClass();
					return new idClass(vec[pos + 1], "", tmp);
				} else {
					parsing_err(
							ERROR,
							toStringz(
							"Identifier or number expected " ~
							"after arithmetic operator"),
							get_buffer(),
							get_buffer().fromStringz.indexOf(vec[pos]));
					assert(0);
				}
			} else {
				// = 7 +
				expressionClass tmp = new expressionClass();
				return new idClass(vec[pos - 1], "", tmp);
			}
		} else {
			return new idClass();
		}
	}
}

alias stdcpp_string = basic_string!(char, char_traits!char);
@system extern (C++) void tokens_into_lists(stdcpp_string* cpp_vec, size_t size)
{
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
				temp.set_str(vec[i - 1]);

				long pos = 0;
				long amount = 0;
				op operation = op.uninitialized;

				if (vec.contains("+") != -1) {
					pos = vec.contains("+");
					operation = op.add;
					amount++;
				}
				if (vec.contains("-") != -1) {
					pos = vec.contains("-");
					operation = op.sub;
					amount++;
				}
				if (vec.contains("*") != -1) {
					pos = vec.contains("*");
					operation = op.mul;
					amount++;
				}
				if (vec.contains("/") != -1) {
					pos = vec.contains("/");
					operation = op.div;
					amount++;
				}
				if (vec.contains("%") != -1) {
					pos = vec.contains("%");
					operation = op.mod;
					amount++;
				}
				if (vec.contains("<<") != -1) {
					pos = vec.contains("<<");
					operation = op.lShift;
					amount++;
				}
				if (vec.contains(">>") != -1) {
					pos = vec.contains(">>");
					operation = op.rShift;
					amount++;
				}
				if (amount == 0) {
					// assume a normal assignment
					temp.set_init(vec[i + 1]);
					lists ~= temp;
					break;
				}
				if (amount > 1) {
					lists ~= handle_multi_expression(vec);
					break;
				}
				idClass v1 = new idClass();
				idClass v2 = new idClass();
				if ((vec[pos - 1] != "=") && (vec[pos + 1] != "=")) {
					v1.set_str(vec[pos - 1]);
					v2.set_str(vec[pos + 1]);
				} else {
					// *= or += or /= ...
					if (vec[pos + 1] == "=") {
						temp.set_str(vec[pos - 1]);
						v1.set_str(vec[pos - 1]);
						if ((pos + 2) > size) {
							logWriteln(logLevel.fatalError,
									"Statement malformed.");
							exit(1);
						}
						v2.set_str(vec[pos + 2]);
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
		gen_ir(id);
		id.destroy();
	}
}
