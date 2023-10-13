module idClass;
import std.stdio : writeln;
import logWriteln : logWriteln, logLevel;
import expressionClass : expressionClass, op;


class idClass {
	// the entire class wraps around this struct
	private struct id {
		string str = "";
		string init = "";
		expressionClass expr;
	};
	private id underlying_struct;
	this() {
		underlying_struct = id("", "", null);
	}
	this(string str, string init, ref expressionClass expr) {
			underlying_struct = id(str, init, expr);
	}
	override string toString() {
		if (this.get_expr is null ||
				this.get_expr().get_operator_() == op.uninitialized) {
			return "struct id:\n.str: " ~  this.get_str() ~ "\n.init: " ~
				this.get_init() ~ "\n.expr: " ~ "(uninitialized)\n";
		} else {
			scope expressionClass tmp = new expressionClass(
					this.get_expr().get_operator_(),
					this.get_expr().get_value1(),
					this.get_expr().get_value2());
			return "struct id:\n.str: " ~ this.get_str() ~ "\n.init: " ~
				this.get_init() ~ "\n.expr: " ~ tmp.toString() ~ "\n";
		}
	}
	@nogc @safe
	void set_str(string str) {
		underlying_struct.str = str;
	}
	@nogc @safe
	void set_init(string init) {
		underlying_struct.init = init;
	}
	@nogc @safe
	void set_expr(ref expressionClass expr) {
		underlying_struct.expr = expr;
	}
	@nogc @safe
	string get_str() const {
		return underlying_struct.str;
	}
	@nogc @safe
	string get_init() const {
		return underlying_struct.init;
	}
	@nogc @safe
	ref expressionClass get_expr() {
		return underlying_struct.expr;
	}

	~this() {
		logWriteln(logLevel.note, "Deleted! (idClass)");
	}
}
