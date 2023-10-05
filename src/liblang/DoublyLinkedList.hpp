#ifndef DOUBLY_LINKED_LIST_HPP
#define DOUBLY_LINKED_LIST_HPP
#include <string>
struct identifier {
	std::string id;
	std::string value;
};
struct DoublyLinkedListNode {
	struct DoublyLinkedListNode *above;
	struct DoublyLinkedListNode *below;
	struct identifier item;
};
class DoublyLinkedList {
private:
	size_t n_;
	struct DoublyLinkedListNode *node;
public:
	DoublyLinkedList(size_t n);

	~DoublyLinkedList();
};
#endif
