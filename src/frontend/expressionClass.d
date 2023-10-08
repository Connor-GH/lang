module expressionClass;
import std.stdio : writeln;
import idClass : idClass;
import logWriteln : logWriteln, logLevel;
import sharedIdentifiers;
enum op {
	uninitialized = 0,
	equals,
	add,
	sub,
	mul,
	div,
	mod,
	rShift,
	lShift,
	addEquals,
	subEquals,
	mulEquals,
	divEquals,
	modEquals,
	rShiftEquals,
	lShiftEquals,
};


class expressionClass {
	// the entire class wraps around this struct
	private struct expression {
		op operator_;
		idClass value1;
		idClass value2;
	};
	private expression underlying_struct;
this() {
	underlying_struct = expression(op.uninitialized, null, null);
}
this(op operator_, ref idClass value1, ref idClass value2) {
	underlying_struct = expression(operator_, value1, value2);
}
override string toString() {
	if (this.get_operator_() == op.uninitialized) {
		writeln("BAD");
	}
	scope idClass v1 = new idClass(this.get_value1().get_str(),
			this.get_value1().get_init(), this.get_value1().get_expr());
	scope idClass v2 = new idClass(this.get_value2().get_str(),
			this.get_value2().get_init(), this.get_value2().get_expr());
	return "struct expression:\n.operator_: " ~ this.get_operator__str() ~
		"\n.value1: " ~ v1.toString() ~ "\n.value2: " ~ v2.toString();
}
op get_operator_() const {
	return underlying_struct.operator_;
}
private string get_operator__str() const {
	final switch (this.get_operator_()) {
	case op.equals: return eq_identifier;
	case op.add: return add_identifier;
	case op.sub: return sub_identifier;
	case op.mul: return mul_identifier;
	case op.div: return div_identifier;
	case op.mod: return mod_identifier;
	case op.rShift: return rs_identifier;
	case op.lShift: return ls_identifier;
	case op.addEquals: return addeq_identifier;
	case op.subEquals: return subeq_identifier;
	case op.mulEquals: return muleq_identifier;
	case op.divEquals: return diveq_identifier;
	case op.modEquals: return modeq_identifier;
	case op.rShiftEquals: return rseq_identifier;
	case op.lShiftEquals: return lseq_identifier;
	case op.uninitialized: return "(uninitialized)";
	}
}
ref idClass get_value1() {
	return underlying_struct.value1;
}
ref idClass get_value2() {
	return underlying_struct.value2;
}
void set_operator_(op operator_) {
	underlying_struct.operator_ = operator_;
}
void set_value1(ref idClass value2) {
	underlying_struct.value2 = value2;
}
void set_value2(ref idClass value2) {
	underlying_struct.value2 = value2;
}
~this() {
	logWriteln(logLevel.note, "Deleted! (expressionClass)");
}
}
