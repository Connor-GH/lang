module logWriteln;
import std.stdio : write, writeln;
import core.stdc.stdlib : exit;
import core.memory : GC;
enum logLevel {
	warning,
	error,
	fatalError,
	note
}

void logWriteln(T ...)(logLevel ll, T t) {

	if (ll == logLevel.warning) {
		write("\033[1;35mWarning: ");
	} else if (ll == logLevel.error) {
		write("\033[1;31mError: ");
	} else if (ll == logLevel.note) {
		write("\033[1;34mNote: ");
	} else if (ll == logLevel.fatalError) {
		write("\033[1;31mError: ");
		write(t);
		writeln("\033[0m");
		GC.collect();
		exit(1);
	}
	write(t);
	writeln("\033[0m");
}
