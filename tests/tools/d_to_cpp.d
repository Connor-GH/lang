import std.stdio : write, writeln, stderr, File;
import std.string : indexOf, tr;
import std.array : replace;

int
main(string[] args)
{
	if (args.length == 1) {
		stderr.writeln("No file specified!");
		return 1;
	}

	// if file ends in ".d"
	if (args[1].indexOf(".d") == (args[1].length - (".d".dup.length))) {
		writeln("#ifndef ", args[1][0 .. $-2].replace("/", "_"), "_hpp");
		writeln("#define ", args[1][0 .. $-2].replace("/", "_"), "_hpp");
		File fp = File(args[1], "r");
		if (fp.error()) {
			stderr.writeln("Error opening file: ", args[1]);
			return 1;
		}
		string s;
		do {
			s = fp.readln();
		} while ((s.indexOf("module") != -1) || (s.indexOf("import") != -1));

		writeln("#include <string>");
		while (!fp.eof()) {
			write(s.replace("immutable", "const")
					  .replace("string", "std::string"));
			s = fp.readln();
		}
		fp.close();
		writeln("#endif /* ", args[1][0 .. $-2].replace("/", "_"), "_hpp */");
	}
	return 0;
}
