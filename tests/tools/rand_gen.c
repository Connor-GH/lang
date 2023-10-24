#include <stdio.h>
#include <stdlib.h>

int main(void) {
	const char *options[] = {
		"boo = boo * c;",
		"ayy = bee;",
		"b = b << c;",
		"a = b - c;",
		"b = c * foo;",
		"this = last;",
		"c = h / a;",
		"remainder = num % div;"
	};

	srand(0x48392230);

	for (int i = 0; i < 100000; i++) {
		srand(rand());
		printf("%s\n", options[rand() % 8]);
	}
	return 0;
}
