module logWriteln;
import std.stdio;
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
	}
	writeln(t);
	write("\033[0m");
}
