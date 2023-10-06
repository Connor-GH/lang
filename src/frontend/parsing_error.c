#include <stdio.h>
#include <stdlib.h>

#include "parsing_error.h"

static const char *file_info = "";
static size_t line_number;
static const char *buffer_ = "";


void set_file(const char *file) {
	file_info = file;
}
void set_line_number(const size_t number) {
	line_number = number;
}
void set_buffer(const char *buffer) {
	buffer_ = buffer;
}
const char *get_buffer(void) {
	return buffer_;
}


void
parsing_err(char warning_level, const char *message, const char *buffer,
			size_t problematic_index)
{
	if (warning_level == ERROR) {
		fprintf(stderr, "%s:%lu:%lu:" RED "error:" CLR " %s\n", file_info,
				line_number, problematic_index, message);
		fprintf(stderr, "%s\n", buffer);
		while (problematic_index > 0) {
			fputc(' ', stderr);
			problematic_index--;
		}
		fprintf(stderr, RED "^\n" CLR);
		exit(EXIT_FAILURE);
	} else if (warning_level == WARNING) {
		fprintf(stderr, "%s:%lu:%lu:" MAGENTA "warning:" CLR " %s\n", file_info,
				line_number, problematic_index, message);
		fprintf(stderr, "%s\n", buffer);
		while (problematic_index > 0) {
			fputc(' ', stderr);
			problematic_index--;
		}
		fprintf(stderr, MAGENTA "^\n" CLR);
	}
}
