#ifndef PARSING_ERROR_H
#define PARSING_ERROR_H
#ifdef __cplusplus
extern "C" {
#include <cstddef>
#else
#include <stddef.h>
#endif
#define ERROR 127
#define WARNING 1
#define RED "\033[1;31m"
#define MAGENTA "\033[1;35m"
#define WHITE "\033[1m"
#define CLR "\033[0m"
void
parsing_err(char warning_level, const char *message, const char *buffer,
			size_t problematic_index);

void set_file(const char *file);
void set_line_number(const size_t number);
void set_buffer(const char *buffer);
const char *get_buffer(void);
#ifdef __cplusplus
}
#endif
#endif
