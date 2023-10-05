#include <string>
#include "liblang/DoublyLinkedList.hpp"

/*     nullptr
 *      ^
 *      |--node--|: above=nullptr, below=node1
 *           ^   V
 *           |--node1--|: above=node, below=node2
 *                ^    V
 *                |--node2--|: above=node1, below=node3
 *                     ^    V
 *                     |--node3--|: above=node2, below=nullptr
 *                               V
 *                               nullptr
 */
DoublyLinkedList::DoublyLinkedList(size_t n) : n_(n) {
	node = new DoublyLinkedListNode;
	DoublyLinkedListNode *head = nullptr;
	node->above = head;
	node->item.value = "";
	for (size_t i = 0; i < n; i++) {
		node->item.value = "";
		node->below = new DoublyLinkedListNode;
		node->below->above = node;
		node = node->below;
	}

}

DoublyLinkedList::~DoublyLinkedList() {
	for (size_t i = 0; i < n_; i++) {
		node = node->above;
		delete node->below;
	}
	delete node;
}
