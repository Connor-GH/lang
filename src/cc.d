import std.stdio : writeln, stderr;
import std.string : indexOf, toStringz;
import std.getopt;
import core.memory : GC;
import core.stdc.stdlib : exit, EXIT_SUCCESS;

extern(C++) void
enter_block_and_parse(const(char) *file);
static const fail = 1;

static void
open_file_to_compile(string file)
{
	if (!file) {
		exit(1);
	} else {
		enter_block_and_parse(file.toStringz());
	}
}
int
main(string[] args)
{
	string output;
	string progname = "{{[sed_name]}}";
	string progversion = "{{[sed_version]}}";
	bool ver = false;
	bool verbose = false;
	bool force = false;
	try {
		auto helpinfo = getopt(args,
				std.getopt.config.caseSensitive,
				"V|verbose", cast(bool *)&verbose,
				"v|version", "Show version info", cast(bool *)&ver,
				std.getopt.config.passThrough,
				"o|output", &output,
				"f|force", "Force file to be compiled", cast(bool *)&force);

		if (helpinfo.helpWanted) {
			defaultGetoptPrinter(progname, helpinfo.options);
			exit(fail);
		}
	} catch (Exception e) {
		stderr.writeln("Error with processing arguments: ", e.msg);
		e.destroy();
		exit(fail);
	}

	if (ver) {
		stderr.writeln(progname, " version ", progversion);
		exit(EXIT_SUCCESS);
	} else if (verbose) {
		/* does nothing for now */
	} else if (output) {
		writeln("Name of output file: ", output);
		for (size_t i = 1; i < args.length; i++) {
			if ((indexOf(args[i], ".fo") != -1) || force) {
				open_file_to_compile(args[i]);
			} else if (args[i] == "-") {
				open_file_to_compile("stdin");
			}
		}
	}
	GC.collect();
	return 0;
}
