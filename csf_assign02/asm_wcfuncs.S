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
	subq $8, %rsp /* adjust stack pointer */	pushq %r12
	pushq %r13
	movq %rdi, %r12 /* copy first param into register for comparison later on */ 
	movq %rsi, %r13 /* copy second param into register for comparison later on */
.LcharsRemaining:
	cmpb $0, (%r12) /* if first param is null terminator, jump to appropriate label */
	je .LfirstParamIsNullTerminator
	cmpb $0, (%r13) /* if second param is null terminator, jump to appropriate label */
	je .LsecondParamIsNullTerminator
	movb (%r12), %dil /* copy first param to %dil register for comparison with second param */
	cmpb %dil, (%r13)
	jb .LfirstParamGreaterThan /* if first param is greater than second param, jump to appropriate label */
	ja .LfirstParamLessThan /* if first param is greater than second param, jump to appropriate label */
	incq %r12 /* increment pointer address to access next char */
	incq %r13 /* increment pointer address to access next char */
	jmp .LcharsRemaining /* repeat loop */

.LfirstParamLessThan:
	movq $-1, %rax /* copy -1 to return register */
	popq %r13
	popq %r12
	addq $8, %rsp /* adjust stack pointer */
	ret
.LfirstParamGreaterThan:
	movq $1, %rax /* copy 1 to return register */
	popq %r13
	popq %r12
	addq $8, %rsp /* adjust stack pointer */
	ret
.LfirstParamIsNullTerminator:
	cmpb $0, (%r13) /* check if 2nd param is also null terminator */
	jne .LfirstParamLessThan /* if second param not null terminator, it means rhs string is less than lhs string, so jump to appropriate label to handle that */
	movq $0, %rax /* if second param is null terminator, then both strings are equal, so copy 0 to return register */
	popq %r13
	popq %r12
	addq $8, %rsp /* adjust stack pointer */
	ret
.LsecondParamIsNullTerminator:
	cmpb $0, (%r12) /* check if 1st param is also null terminator */
	jne .LfirstParamGreaterThan /* if 1st param not null terminator, it means rhs string is greater than lhs string, so jump to appropriate label  */
	movq $0, %rax /* if second param is also a null terminator, then both strings are equal so copy 0 to return register */
	popq %r13
	popq %r12
	addq $8, %rsp /* adjust stack pointer */
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
	// movb %r8b, (%rdi)
	incq %rsi // Increment source pointer
	incq %rdi // Increment dest pointer
	jmp .LWhileStillCopyingString
.LdoneCopying:
	movb $0, (%rdi) // copy over the null terminator to dest index
	// movb $'\0', (%rdi)
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
	subq $8, %rsp 			/* adjust stack pointer */
	cmp  $'A', %rdi
	jl .Lnot_alpha
	cmp $'Z', %rdi

	jle .Lis_alpha
	cmp $'a', %rdi
	jl .Lnot_alpha
	cmp  $'z', %rdi
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

	subq $8, %rsp
	mov $0, %r8				/* counter */

	.Lskip_whitespace:		/* skipping whitespace */

		pushq %rdi
		call fgetc			/* get next character */
		popq %rdi

		cmp $3, %al			/* if EOF, done */
		je .Ldone

		pushq %rdi
		mov %rax, %rdi
		movb %al, %r9b
		call wc_isspace
		popq %rdi
		cmp $1, %rax		/* if whitespace, continue skipping */
		je .Lskip_whitespace

	.Lread:
		cmp $1, %rax		/* if whitespace, done */
		je .Ldone

		cmp $63, %r8		/* if max wordlen read, done */
		je .Ldone

		movb %r9b, (%rsi, %r8)	/* move character to array */
		inc %r8

		pushq %rdi
		call fgetc				/* get next character */
		mov %rax, %rdi
		movb %al, %r9b

		call wc_isspace
		popq %rdi
		jmp .Lread

	.Ldone:
		cmp $0, %r8
		je .Lunsuccessful
		movb $0, (%rsi, %r8)	/* add null terminator */
		mov $1, %rax 		/* word reading success */
		addq $8, %rsp
		ret

	.Lunsuccessful:
		mov $0, %rax
		addq $8, %rsp
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
	movb (%rdi), %r8b
	cmpb $0, %r8b // is it a null terminator
	je .Lloop_done
	cmpb $65, %r8b // rdi >= 65 (65 is ascii for 'A')
	jl .LdoesntMeetComp
	cmpb $90, %r8b // rdi <= 90 (90 is ascii for 'Z')
	jg .LdoesntMeetComp
	addb $32, %r8b
	movb %r8b, (%rdi)
.LdoesntMeetComp:
	incq %rdi
	jmp .LforLoop
.Lloop_done:
	addq $8, %rsp
	ret

/* // From example code on Assignment2 Course Site
 * Determine the length of specified character string.
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *
 * Returns:
 *    number of characters in the string
 */
	.globl strLen
strLen:
	subq $8, %rsp                 /* adjust stack pointer */
	movq $0, %r10                 /* initial count is 0 */

.LstrLenLoop:
	cmpb $0, (%rdi)               /* found NUL terminator? */
	jz .LstrLenDone               /* if so, done */
	inc %r10                      /* increment count */
	inc %rdi                      /* advance to next character */
	jmp .LstrLenLoop              /* continue loop */

.LstrLenDone:
	movq %r10, %rax               /* return count */
	addq $8, %rsp                 /* restore stack pointer */
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

	subq $8, %rsp
	mov $0, %rcx
	movq %rdi, %rdx			/* rdx now points to current char */

	.Lfind_end_loop:
		movb (%rdx), %bl		/* copy first char of string into a one byte register */
		cmp $0, %bl				/* If null terminator, done */
		je .Ltrim_loop
		inc %rdx
		inc %rcx
		jmp .Lfind_end_loop

	.Ltrim_loop:
		decq %rdx
		dec %rcx
		movb (%rdx), %bl
		movzbq %bl, %rdi
		subq $8, %rsp
		call wc_isalpha
		addq $8, %rsp
		cmp $1, %rax
		je .Lfinish
		jmp .Ltrim_loop
		
	.Lfinish:
		incq %rdx
		movb $0, (%rdx)
		addq $8, %rsp
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
 	/* TODO: implement */
 	subq $8, %rsp // align stack ptr
 	pushq %rbx // saving callee-saved register %rbx = itr 
 	pushq %rcx // saving callee-saved register %rcx = entry
 	pushq %r12 // saving callee-saved register %r12 = s
 	pushq %r13 // saving callee-sasved register %13 = inserted address
 	pushq %r14 // saving callee-saved register %r14 = head ptr
 	movq %rdi, %r14 // saving head pointer
 	movq %rdx, %r13 // saving pointer of inserted to r13
 	movq %rsi, %r12 // saving pointer s to r12
 	movq %rdi, %rbx // save address of head pointer to itr pointer variable
 .LwhileElementsInList:
 	cmpq $0, %rbx // check if itr is null
 	je .LendOfList // if itr at end, we're at end of list and can terminate
 	// put itr.word into rdi // itr.word is first part of struct
 	movq %rbx, %rdi
 	// put s into rsi
 	movq %r12, %rsi
 	// set iterator to next element // itr is pointer to struct, so beginning address of it should be at 64 + 4 + 4 (padding)
 	leaq 72(%rbx), %rbx // get memory address of next pointer
	movq (%rbx), %rbx // get actual next itr
	// addq $72, %rbx  
	// call wc_str_compare // TODO: adjust stack ptr before calling
 	// subq $8, %rsp
	call wc_str_compare
 	//addq $8, %rsp
 	// check if rax is 0
 	cmpq $0, %rax
 	// if not 0, jump to top again
 	jne .LwhileElementsInList
 	// else:
 		// set value of inserted to 0
 	movq $0, (%r13)
 		// store itr to rax
 	leaq -72(%rbx), %rbx
	movq %rbx, %rax
	// subq $72, %rbx
 	jmp .LrestoreCalleeValuesAndReturn 
 .LendOfList:
 	// move sizeof WordEntry into rdi // 64 (word) + 4 (count) + 4 (padding) + 8 (next pointer) = 80
 	movq $80, %rdi
 	// call malloc
 	call malloc
 	// move result of malloc, i.e. %rax, into %rcx
 	movq %rax, %rcx // rcx is now new entry pointer
 	// {copy word to entry->word, which is first part of word entry}
 		// to do so, move entry.word to rdi
 	movq %rcx, %rdi
 		// and s to rsi
 	movq %r12, %rsi
 	call wc_str_copy
 	// {set count of wordEntry to 0}; count is 40 bits away from end
 	movl $0, 64(%rcx) // caution: moving 4 bytes? is there any potential issues?
 	// {set next of the wordEntry. next is the last part of word entry and 8 bits away from ending
 	movq %r14, 72(%rcx) // 72 bytes cuz 64 bytes from word, 4 bytes from count + 4 padding to make it multiple of 8
 	// set inserted param value to 1. (3rd param)
 	movq $1, (%r13)
 	// copy entry to rax
 	movq %rcx, %rax
 .LrestoreCalleeValuesAndReturn:
 	popq %r14
 	popq %r13
 	popq %r12
 	popq %rcx
 	popq %rdx
 	addq $8, %rsp
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
	/* TODO: implement */
	ret

/*
 * Free all of the nodes in given linked list of WordEntry objects.
 *
 * C function prototype:
 *    void wc_free_chain(struct WordEntry *p);
 */
	.globl wc_free_chain
wc_free_chain:
	/* TODO: implement */
	ret

/*
vim:ft=gas:
*/
