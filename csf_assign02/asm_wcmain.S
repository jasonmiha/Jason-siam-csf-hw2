/*
 * Assembly language main function implementation
 */

#define MAX_WORDLEN 63
#define HASHTABLE_SIZE 50000000 
#define stdin stdin

	.section .text

	.globl main
main:
	subq $8, %rsp // Align stack ptr
 	pushq %rbx // Saving callee-saved register %rbx = totalWords 
 	pushq %rcx // Saving callee-saved register %rcx = uniqueWords
 	pushq %r12 // Saving callee-saved register %r12 = bestWord
 	pushq %r13 // Saving callee-saved register %r13 = bestWordCount
 	pushq %r14 // Saving callee-saved register %r14 = buckets
 	pushq %r15 // Saving callee-saved register %r15 = fp (File*)
	movq $0, %rbx // Initialize total words with 0
	movq $0, %rcx // Initialize unique words with 0
	movq $'\0', %r12 // Init best word with empty string 
	movq $0, %r13 // Init bestWordCount with 0
	
	cmpq $1, %rdi // Check if argc is 1
	jne .LopenFile
	// movq stdin, %r15 // Set reference of fp to stdin
	jmp .LafterOpenedFile

.LopenFile:

.LafterOpenedFile:

/*
vim:ft=gas:
*/
