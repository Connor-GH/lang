module logWriteln;
import core.memory : GC;
import core.stdc.stdlib : exit;
import std.stdio : write, writeln;
enum logLevel {
	warning,
	error,
	fatalError,
	note
}

void logWriteln(T ...)(logLevel ll, T t) {

	with (logLevel) {
		switch(ll) {
			case warning: write("\033[1;35mWarning: "); break;
			case error: write("\033[1;31mError: "); break;
			case fatalError: {
				write("\033[1;31mError: ");
				write(t);
				writeln("\033[0m");
				GC.collect();
				exit(1);
			}
			case note: write("\033[1;34mNote: "); break;
			default: break;
		}
	}
	write(t);
	writeln("\033[0m");
}
