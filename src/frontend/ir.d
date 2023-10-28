module ir;
import std.stdio : writeln;
import idClass : idClass;
import expressionClass : op;

static string gen_instruction(idClass ast)
{
	op o = ast.get_expr().get_operator_();
	idClass v1 = ast.get_expr().get_value1();
	idClass v2 = ast.get_expr().get_value2();
	string result = "";
	with (op) {
		switch (o) {
		case add:
			result ~= "add(";
			break;
		case sub:
			result ~= "sub(";
			break;
		case mul:
			result ~= "mul(";
			break;
		case div:
			result ~= "div(";
			break;
		case mod:
			result ~= "mod(";
			break;
		case rShift:
			result ~= "rs(";
			break;
		case lShift:
			result ~= "ls(";
			break;
		case addEquals:
			result ~= "add(";
			break;
		case subEquals:
			result ~= "sub(";
			break;
		case mulEquals:
			result ~= "mul(";
			break;
		case divEquals:
			result ~= "div(";
			break;
		case modEquals:
			result ~= "mod(";
			break;
		case rShiftEquals:
			result ~= "rs(";
			break;
		case lShiftEquals:
			result ~= "ls(";
			break;
		default:
			break;
		}
	}

	result ~= ast.get_str() ~ ", ";
	result ~= v1.get_str() ~ ", ";
	result ~= v2.get_str() ~ ")";
	return result;
}

void gen_ir(idClass ast)
{
	string ir;

	if (ast.get_expr() !is null) {
		ir = gen_instruction(ast);
	}
	writeln(ir);
}
