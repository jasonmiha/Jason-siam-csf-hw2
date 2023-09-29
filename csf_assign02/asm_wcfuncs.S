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
	subq $8, %rsp		/* align stack pointer */
	mov $1, %ecx		/* loop counter */
	jmp .LcheckCond

	.Ltop:										/* loop body */
		hash_code = hash_code * 33 + w[%ecx] 	/* update hash */
		inc %ecx								/* increment loop counter */

	.LcheckCond:
		cmp %ecx, len(w)		/* loop condition */
		jX .Ltop				/* terminates loop */

	mov hash_code, %rax			/* return hashcode */
	addq $8, %rsp				/* realign stack pointer */
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
	subq $8, %rsp /* adjust stack pointer */
	mov %rdi, %r12 /* copy first param into register for comparison later on */ 
	mov %rsi, %r11 /* copy second param into register for comparison later on */
.LcharsRemaining:
	cmp $'\0', (%r12) /* if first param is null terminator, jump to appropriate label */
	je .LfirstParamIsNullTerminator
	cmp $'\0', (%r11) /* if second param is null terminator, jump to appropriate label */
	je .LsecondParamIsNullTerminator
	mov (%r12), %dil /* copy first param to %dil register for comparison with second param */
	cmp %dil, (%r11)
	jl .LfirstParamGreaterThan /* if first param is greater than second param, jump to appropriate label */
	jg .LfirstParamLessThan /* if first param is greater than second param, jump to appropriate label */
	incq %r12 /* increment pointer address to access next char */
	incq %r11 /* increment pointer address to access next char */
	jmp .LcharsRemaining /* repeat loop */

.LfirstParamLessThan:
	mov $-1, %rax /* copy -1 to return register */
	addq $8, %rsp /* adjust stack pointer */
	ret
.LfirstParamGreaterThan:
	mov $1, %rax /* copy 1 to return register */
	addq $8, %rsp /* adjust stack pointer */
	ret
.LfirstParamIsNullTerminator:
	cmp $'\0', (%r11) /* check if 2nd param is also null terminator */
	jne .LfirstParamLessThan /* if second param not null terminator, it means rhs string is less than lhs string, so jump to appropriate label to handle that */
	mov $0, %rax /* if second param is null terminator, then both strings are equal, so copy 0 to return register */
	addq $8, %rsp /* adjust stack pointer */
	ret
.LsecondParamIsNullTerminator:
	cmp $'\0', (%r12) /* check if 1st param is also null terminator */
	jne .LfirstParamGreaterThan /* if 1st param not null terminator, it means rhs string is greater than lhs string, so jump to appropriate label  */
	mov $0, %rax /* if second param is also a null terminator, then both strings are equal so copy 0 to return register */
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
	/* TODO: implement */
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
	/* TODO: implement */
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
	/* TODO: implement */
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
	/* TODO: implement */
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
