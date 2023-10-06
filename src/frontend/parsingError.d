module parsingError;
extern(C) void parsing_err(char warning_level, const char *message,
					const char *buffer, size_t problematic_index);
extern(C) void set_file(const char *file);
extern(C) void set_line_number(const size_t number);
extern(C) const(char *)get_buffer();
extern(C) void set_buffer(const char *buffer);
immutable int ERROR = 127;
immutable int WARNING = 1;
