/*
 * Assembly language function implementations
 */

#define MAX_WORDLEN 63

/*
 * Offsets for the fields of the struct WordEntry data type
 * (Note that there is 4 bytes of padding between the count and next
 * fields.)
 */
#define WORDENTRY_WORD_OFFSET   (0)
#define WORDENTRY_COUNT_OFFSET  (MAX_WORDLEN+1)
#define WORDENTRY_NEXT_OFFSET   (MAX_WORDLEN+1+4+4)

	.section .rodata
/* Define any string constants or read-only data here */

	.section .text

/*
 * Compute a hash code for the given NUL-terminated
 * character string.
 *
 * The hash algorithm should be implemented as follows:
 *
 * uint32_t hash_code = 5381
 * for each character c of w in order {
 *   hash_code = hash_code * 33 + c
 * }
 *
 * Note that the character values should be treated as
 * being unsigned (in the range 0..255)
 *
 * C function prototype:
 *    uint32_t wc_hash(const unsigned char *w);
 */
	.globl wc_hash
wc_hash:
	subq $8, %rsp				/* align stack pointer */
	mov $5381, %rax				/* initialize hash value */

	.Ltop:	
		movb (%rdi), %bl		/* copy first char of string into a one byte register */
		cmp $0, %bl				/* If null terminator, done */
		je .Lend
		mov $33, %r11			/* temp variable */
		mul %r11				/* hash_code * 33 */
		movzbq %bl, %rbx		/* zero extend char value */
		add %rbx, %rax			/* hash_code + c */
	 	inc %rdi				/* move to the next char */
		jmp .Ltop
	
	.Lend:
		addq $8, %rsp			/* restore stack pointer */
		ret

/*
 * Compare two strings lexicographically. Return
 *
 * - a negative value if lhs string is less than rhs string
 * - 0 if lhs string is identical to rhs string
 * - a positive value if lhs string is greater than rhs string
 *
 * Lexicographical comparison is a generalization of alphabetical
 * order, but using character codes. If one string is a prefix
 * of the other, it is considered as "less than". E.g.,
 * "hi" would compare as less than "high".
 *
 * C function prototype:
 *    int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs);
 */

	.globl wc_str_compare
wc_str_compare:
	subq $24, %rsp // Adjust stack pointer	
	pushq %r12 // Save callee register r12
	pushq %r13 // Save callee register r13
	movq %rdi, %r12 // Copy first param into register for comparison later on 
	movq %rsi, %r13 // Copy second param into register for comparison later on 
.LcharsRemaining:
	cmpb $0, (%r12) // If first param is null terminator, jump to appropriate label
	je .LfirstParamIsNullTerminator
	cmpb $0, (%r13) // If second param is null terminator, jump to appropriate label 
	je .LsecondParamIsNullTerminator
	movb (%r12), %dil // Copy first param to %dil register for comparison with second param 
	cmpb %dil, (%r13)
	jb .LfirstParamGreaterThan // If first param is greater than second param, jump to appropriate label
	ja .LfirstParamLessThan // If first param is greater than second param, jump to appropriate label
	incq %r12 // Increment pointer address to access next char
	incq %r13 // Increment pointer address to access next char
	jmp .LcharsRemaining // Repeat loop

.LfirstParamLessThan:
	movq $-1, %rax // Copy -1 to return register 
	popq %r13
	popq %r12
	addq $24, %rsp // Adjust stack pointer 
	ret
.LfirstParamGreaterThan:
	movq $1, %rax // Copy 1 to return register 
	popq %r13
	popq %r12
	addq $24, %rsp // Adjust stack pointer
	ret
.LfirstParamIsNullTerminator:
	cmpb $0, (%r13) // Check if 2nd param is also null terminator 
	jne .LfirstParamLessThan // If second param not null terminator, it means rhs string is less than lhs string, so jump to appropriate label to handle that 
	movq $0, %rax // If second param is null terminator, then both strings are equal, so copy 0 to return register 
	popq %r13
	popq %r12
	addq $24, %rsp // Adjust stack pointer 
	ret
.LsecondParamIsNullTerminator:
	cmpb $0, (%r12) // Check if 1st param is also null terminator
	jne .LfirstParamGreaterThan // If 1st param not null terminator, it means rhs string is greater than lhs string, so jump to appropriate label 
	movq $0, %rax // If second param is also a null terminator, then both strings are equal so copy 0 to return register 
	popq %r13
	popq %r12
	addq $24, %rsp // Adjust stack pointer 
	ret
	
/*
 * Copy NUL-terminated source string to the destination buffer.
 *
 * C function prototype:
 *    void wc_str_copy(unsigned char *dest, const unsigned char *source);
 */
	.globl wc_str_copy
wc_str_copy:
	subq $8, %rsp
.LWhileStillCopyingString:
	movb (%rsi), %al // Get source character and store into al register
	cmpb $0, %al // Is it a null terminator
	je .LdoneCopying // If so, finished copying
	movb %al, (%rdi) // Copy source char to dest char
	incq %rsi // Increment source pointer
	incq %rdi // Increment dest pointer
	jmp .LWhileStillCopyingString
.LdoneCopying:
	movb $0, (%rdi) // Copy over the null terminator to dest index
	addq $8, %rsp
	ret	


/*
 * Return 1 if the character code in c is a whitespace character,
 * false otherwise.
 *
 * For the purposes of this function, a whitespace character is one of
 *
 *   ' '
 *   '\t'
 *   '\r'
 *   '\n'
 *   '\f'
 *   '\v'
 *
 * C function prototype:
 *    int wc_isspace(unsigned char c);
 */
	.globl wc_isspace
wc_isspace:
	subq $8, %rsp /* adjust stack pointer */
	cmp $32, %rdi /* check if its a space */
	je .Lisspace /* jump to isspace label if input param is equal to space */
	cmp $9, %rdi /* check if its '\t' */
	je .Lisspace 
	cmp $13, %rdi /* check if its '\r' */
	je .Lisspace
	cmp $10, %rdi /* check if its '\n' */
	je .Lisspace
	cmp $12, %rdi /* check if its '\f' */
	je .Lisspace
	cmp $11, %rdi /* check if its '\v' */
	je .Lisspace

	/* if it gets to this point, 
	it means it is not a space character */
	mov $0, %rax /* copy 0 to return variable */
	addq $8, %rsp /* adjust stack pointer */
	ret
	
.Lisspace: /* if it gets to this point, it is a whitespace character */
	mov $1, %rax /* copy 1 to return variable to indicate that it's a whitespace character */
	addq $8, %rsp /* adjust stack pointer */
	ret


/*
 * Return 1 if the character code in c is an alphabetic character
 * ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
 *
 * C function prototype:
 *    int wc_isalpha(unsigned char c);
 */
.globl wc_isalpha
wc_isalpha:
	subq $8, %rsp 			/* Adjust stack pointer */
	cmp  $'A', %rdi 		/* Check if it's >= to A */
	jl .Lnot_alpha			
	cmp $'Z', %rdi			/* Check if it's <= to Z */
	jle .Lis_alpha
	cmp $'a', %rdi			/* Check if it's >= to a */
	jl .Lnot_alpha
	cmp  $'z', %rdi			/* Check if it's <= to z */
	jle .Lis_alpha

.Lnot_alpha:
	mov $0, %rax
	addq $8, %rsp
	ret

.Lis_alpha:
 	mov $1, %rax
	addq $8, %rsp
	ret

/*
 * Read the next word from given input stream, storing
 * the word in the array pointed-to by w. (This array should be
 * assumed to be MAX_WORDLEN+1 elements in size.) Return 1
 * if a word is read successfully, 0 otherwise.
 *
 * For the purposes of this function, a word is a sequence of
 * 1 or more non-whitespace characters.
 *
 * If a sequence of non-whitespace characters has more than
 * MAX_WORDLEN characters, then only the first MAX_WORDLEN
 * characters in the sequence should be stored in the array.
 *
 * C function prototype:
 *    int wc_readnext(FILE *in, unsigned char *w);
 */
	.globl wc_readnext
wc_readnext:

	subq $40, %rsp

	pushq %rbx // Saving callee-saved register %rbx = curr char
 	pushq %r13 // Saving callee-saved register %r13 = value of rdi
	pushq %r14 // Saving callee-saved register %r14 = counter
	pushq %r15 // Saving callee-saved register %r15 = string

	movq $0, %r14				/* counter */
	movq %rdi, %r13				/* save rdi value to be assigned back later */
	movq %rsi, %r15

	.Lskip_whitespace:		/* skipping whitespace */

		movq %r13, %rdi		/* reset value of rdi */
		call fgetc			/* get next character */

		cmpb $-1, %al			/* if EOF, done */
		je .Ldone

		mov %rax, %rdi		/* move char into argument register */
		movb %al, %bl		/* move char into 8 bit subregister */
		call wc_isspace		/* if whitespace, continue skipping */
		cmp $1, %rax		
		je .Lskip_whitespace	/* loop back to continue skipping whitespace */

	.Lread:
		cmp $1, %rax		/* if whitespace, done */
		je .Ldone

		cmp $63, %r14		/* if max wordlen read, done */
		je .Ldone

		mov %rbx, (%r15, %r14)	/* move character to array */
		inc %r14

		movq %r13, %rdi			/* reset value of rdi */
		call fgetc				/* get next character */
		movb %al, %bl			/* move char into 8 bit subregister */
		mov %rax, %rdi			/* move char into argument register */

		cmpb $-1, %bl			/* if EOF, done */
		je .Ldone

		call wc_isspace			/* call isspace to be used at top of loop */
		jmp .Lread

	.Ldone:
		cmp $0, %r14				/* if 0 characters read, unsuccessful */
		je .Lunsuccessful
		movb $0, (%r15, %r14)				/* add null terminator */
		mov $1, %rax 				/* word reading success */

		popq %r15 // Restoring callee-saved register %r15 = string
		popq %r14 // Restoring callee-saved register %r14 = counter
		popq %r13 // Restoring callee-saved register %r13 = value of rdi
		popq %rbx // Restoring callee-saved register %rbx = curr char
		addq $40, %rsp // Restoring stack pointer
		ret

	.Lunsuccessful:
		mov $0, %rax

		popq %r15 // Restoring callee-saved register %r15 = string
		popq %r14 // Saving callee-saved register %r14 = counter
		popq %r13 // Restoring callee-saved register %r13 = value of rdi
		popq %rbx // Saving callee-saved register %rbx = curr char
		addq $40, %rsp	// Restoring stack pointer
		ret



/*
 * Convert the NUL-terminated character string in the array
 * pointed-to by w so that every letter is lower-case.
 *
 * C function prototype:
 *    void wc_tolower(unsigned char *w);
 */
	.globl wc_tolower
wc_tolower:
	subq $8, %rsp
.LforLoop:
	movb (%rdi), %r8b // Store char at rdi to r8b
	cmpb $0, %r8b // Is it a null terminator
	je .Lloop_done // If so, finish the function
	cmpb $65, %r8b // rdi >= 65 (65 is ascii for 'A')
	jl .LdoesntMeetComp 
	cmpb $90, %r8b // rdi <= 90 (90 is ascii for 'Z')
	jg .LdoesntMeetComp
	addb $32, %r8b // Add by 32 to convert to lowercase, in ASCII
	movb %r8b, (%rdi) 
.LdoesntMeetComp:
	incq %rdi // Increment pointer to next char
	jmp .LforLoop
.Lloop_done:
	addq $8, %rsp
	ret

/*
 * Remove any non-alphaabetic characters from the end of the
 * NUL-terminated character string pointed-to by w.
 *
 * C function prototype:
 *    void wc_trim_non_alpha(unsigned char *w);
 */
	.globl wc_trim_non_alpha
wc_trim_non_alpha:

	subq $8, %rsp			/* Align stack pointer */
	mov $0, %rcx			/* Initialize counter to 0 */
	movq %rdi, %rdx			/* rdx now points to current char */

	.Lfind_end_loop:			/* Loop to find position of null terminator */
		movb (%rdx), %bl		/* copy first char of string into a one byte register */
		cmp $0, %bl				/* If null terminator, done */
		je .Ltrim_loop
		inc %rdx				/* Increment pointer */
		inc %rcx				/* Increment counter */
		jmp .Lfind_end_loop

	.Ltrim_loop:				/* Loop to trim non-alpha starting from end */
		decq %rdx				/* Go back one from null terminator to last char */
		dec %rcx				/* Decrement counter */
		movb (%rdx), %bl		/* Move char to 8 bit subregister */
		movzbq %bl, %rdi		/* Move back into argument register and pad with 0s */
		subq $8, %rsp
		call wc_isalpha			/* Align stack pointer and call isalpha */
		addq $8, %rsp
		cmp $1, %rax			/* If alpha, finish*/
		je .Lfinish
		jmp .Ltrim_loop			/* Otherwise keep looping */
		
	.Lfinish:
		incq %rdx				/* Go to one past the last character */
		movb $0, (%rdx)			/* Add null terminator */
		addq $8, %rsp			/* Restore stack pointer */
		ret

/*
 * Search the specified linked list of WordEntry objects for an object
 * containing the specified string.
 *
 * If a matching object is found, set the int variable pointed-to by
 * inserted to 0 and return a pointer to the matching object.
 *
 * If a matching object is not found, allocate a new WordEntry object,
 * set its next pointer to point to what head points to (i.e., so the
 * new object is at the head of the list), set the variable pointed-to
 * by inserted to 1, and return a pointer to the new node. Note that
 * the new node should have its count value set to 0. (It is the caller's
 * job to update the count.)
 *
 * C function prototype:
 *    struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted);
 */
	.globl wc_find_or_insert
wc_find_or_insert:
 	subq $16, %rsp // Align stack ptr
 	pushq %rbx // Saving callee-saved register %rbx = itr 
 	pushq %rbp // Saving callee-saved register %rbp = entry
 	pushq %r12 // Saving callee-saved register %r12 = s
 	pushq %r13 // Saving callee-saved register %r13 = inserted address
 	pushq %r14 // Saving callee-saved register %r14 = head ptr
 	movq %rdi, %r14 // Saving head pointer
 	movq %rdx, %r13 // Saving pointer of inserted to r13
 	movq %rsi, %r12 // Saving pointer s to r12
 	movq %rdi, %rbx // Save address of head pointer to itr pointer variable
 .LwhileElementsInList:
	cmpq $0, %rbx // Check if itr is null
	je .LendOfList // If itr at end, we're at end of list and can terminate
 	// Continue with for loop
	movq %rbx, %rdi // Save itr->word to 1st param for string comparison
 	movq %r12, %rsi // Save s to 2nd param for string comparison

	call wc_str_compare // Check if itr->word is equal to s

 	cmpq $0, %rax
 	// If not equal, increment ptr and repeat loop
	jne .LincrementPtrAndRepeat
 	// If strings are equal:
 	movq $0, (%r13) // Set value of inserted to 0
	movq %rbx, %rax // Save itr to return 
 	jmp .LrestoreCalleeValuesAndReturn 

.LincrementPtrAndRepeat:
 	// Set iterator to next element; itr is pointer to struct, so it's at beginning address of next
 	movq WORDENTRY_NEXT_OFFSET(%rbx), %rbx
	jmp .LwhileElementsInList
	
 .LendOfList:
 	movq $80, %rdi // Move sizeof(struct WordEntry) = 80 (64 word, 4 count, 4 padding, 8 next ptr) to %rdi
 	call malloc // Allocate memory of size 80
 	movq %rax, %rbp // Store ptr returned by malloc to rbp, which is now the entry pointer
	// Copy word to entry->word
 	movq %r14, WORDENTRY_NEXT_OFFSET(%rbp) // Set next WordEntry ptr of entry to head
 	movl $0, WORDENTRY_COUNT_OFFSET(%rbp) // Set count of entry to 0 
 	movq %rbp, %rdi // Save entry->word to rdi
 	movq %r12, %rsi // Save s to rsi
 	call wc_str_copy // Copy s to entry->word
 	movq %rbp, %rax // Save entry to return variable
 	movq $1, (%r13) // Set inserted value to 1
 .LrestoreCalleeValuesAndReturn:
 	popq %r14 // Restoring callee-saved register %r14
 	popq %r13 // Restoring callee-saved register %r13
 	popq %r12 // Restoring callee-saved register %r12
 	popq %rbp // Restoring callee-saved register %rbp
 	popq %rbx // Restoring callee-saved register %rbx
 	addq $16, %rsp // Align stack ptr
 	ret
 
/*
 * Find or insert the WordEntry object for the given string (s), returning
 * a pointer to it. The head of the linked list which contains (or should
 * contain) the entry for s is the element of buckets whose index is the
 * hash code of s mod num_buckets.
 *
 * Returns a pointer to the WordEntry object in the appropriate linked list
 * which represents s.
 *
 * C function prototype:
 *    struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s);
 */
.globl wc_dict_find_or_insert
wc_dict_find_or_insert:
//  Save all callee saved values and init them
  pushq %r12 // Saving callee-saved register r12 = buckets
  pushq %r13 // Saving callee-saved register r13 = num_buckets
  pushq %r14 // Saving callee-saved register r14 = s
  pushq %r15 // Saving callee-saved register r15 => temporary values

  movq %rdi, %r12 // Store buckets in r12
  movq %rsi, %r13 // Store num_buckets in r13
  movq %rdx, %r14 // Save s in r14

  movq %r14, %rdi // Move s to rdi to pass into wc_hash
  call wc_hash // it returns a uint32
  movl $0, %edx
  movl %eax, %r15d // r15 holds wc_hash which is uint32
  // movslq %r15d, %rax/ movq $0, %rdx
  divl %r13d // Divide rdx:rax by r13
  movl %edx, %r15d // Store remainder of division to r15

  movq (%r12, %r15, 8), %rdi // Store address of buckets[index] into first param

  movq %r14, %rsi // Move s to rsi
  leaq -16(%rsp), %rdx // Move address of 'inserted' to rdx (3rd param)
  movl $0, (%rdx) // Save 0 into inserted
  pushq %rdx // save inserted pointer to stack 
  subq $8, %rsp // Align stack
  call wc_find_or_insert 
  addq $8, %rsp // Align stack
  popq %rdx // pop inserted pointer from stack
  cmpl $0, (%rdx) // Check if it's been inserted
  je .LdictFindRestoreAndReturn // If not, no need to do anything extra, just return
  movq %rax, (%r12, %r15, 8) // If it's been inserted, then we gotta save it to the buckets memory as well
.LdictFindRestoreAndReturn:
  // Restore saved registers
  popq %r15
  popq %r14
  popq %r13
  popq %r12

  ret

/*
 * Free all of the nodes in given linked list of WordEntry objects.
 *
 * C function prototype:
 *    void wc_free_chain(struct WordEntry *p);
 */
	.globl wc_free_chain
wc_free_chain:
	subq $24, %rsp
	pushq %r15 // Save callee register r15 = itr
	pushq %r14 // Save callee register r14 = prev
	movq %rdi, %r15 // Set value of r15
	movq $0, %r14 // Set value of r14
// While elements left
.LfreeChainWhileElementsInChain:
	cmpq $0, %r15 // Check if itr is null
	je .LfreeChainRestoreCalleeSavedRegistersAndReturn // If null, jump outside loop
	movq %r15, %r14 // Copy itr to prev
	// Set next itr
	leaq 72(%r15), %r15 // Get memory address of where next pointer is stored
	movq (%r15), %r15 // Set next itr
	movq %r14, %rdi // Store prev to rdi
	call free
	jmp .LfreeChainWhileElementsInChain // Repeat loop
.LfreeChainRestoreCalleeSavedRegistersAndReturn:
	popq %r14
	popq %r15
	addq $24, %rsp
	ret

/*
vim:ft=gas:
*/
