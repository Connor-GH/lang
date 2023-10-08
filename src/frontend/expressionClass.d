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
this(op operator_, idClass value1, idClass value2) {
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
string[op] op_arr_rev = [
		op.equals: eq_identifier,
		op.add: add_identifier,
		op.sub: sub_identifier,
		op.mul: mul_identifier,
		op.div: div_identifier,
		op.mod: mod_identifier,
		op.rShift: rs_identifier,
		op.lShift: ls_identifier,
		op.addEquals: addeq_identifier,
		op.subEquals: subeq_identifier,
		op.mulEquals: muleq_identifier,
		op.divEquals: diveq_identifier,
		op.modEquals: modeq_identifier,
		op.rShiftEquals: rseq_identifier,
		op.lShiftEquals: lseq_identifier,
		op.uninitialized: "(uninitialized)"
	];
	return op_arr_rev[this.get_operator_()];
}
idClass get_value1() {
	return underlying_struct.value1;
}
idClass get_value2() {
	return underlying_struct.value2;
}
void set_operator_(op operator_) {
	underlying_struct.operator_ = operator_;
}
void set_value1(idClass value2) {
	underlying_struct.value2 = value2;
}
void set_value2(idClass value2) {
	underlying_struct.value2 = value2;
}
~this() {
	logWriteln(logLevel.note, "Deleted! (expressionClass)");
}
}
