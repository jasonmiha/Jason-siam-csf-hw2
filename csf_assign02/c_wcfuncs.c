// Important: do not add any additional #include directives!
// The only C library functions that may be used are
//
// - fgetc
// - malloc
// - free

#include <stdlib.h>
#include "wcfuncs.h"

// Compute a hash code for the given NUL-terminated
// character string.
//
// The hash algorithm should be implemented as follows:
//
// uint32_t hash_code = 5381
// for each character c of w in order {
//   hash_code = hash_code * 33 + c
// }
//
// Note that the character values should be treated as
// being unsigned (in the range 0..255)
uint32_t wc_hash(const unsigned char *w)
{
  uint32_t hash_code = 5381;
  int l = wc_strlen(w);

  for (int i = 0; i < l; i++)
  {
    hash_code = hash_code * 33 + w[i];
  }
  return hash_code;
}

// Compare two strings lexicographically. Return
//
// - a negative value if lhs string is less than rhs string
// - 0 if lhs string is identical to rhs string
// - a positive value if lhs string is greater than rhs string
//
// Lexicographical comparison is a generalization of alphabetical
// order, but using character codes. If one string is a prefix
// of the other, it is considered as "less than". E.g.,
// "hi" would compare as less than "high".
int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs)
{

  while (*lhs && *rhs)
  {
    if (*lhs < *rhs)
      return -1; // lhs is less than rhs
    if (*lhs > *rhs)
      return 1; // lhs is greater than rhs
    lhs++;
    rhs++;
  }
  if (*lhs == '\0' && *rhs == '\0')
    return 0; // identical strings
  else if (*lhs == '\0')
    return -1; // lhs is a prefix of rhs
  else
    return 1; // rhs is a prefix of lhs
}

// Copy NUL-terminated source string to the destination buffer.
void wc_str_copy(unsigned char *dest, const unsigned char *source)
{
  int len = wc_strlen(source);
  // copies up to and including '\0'
  for (int i = 0; i <= len; i++)
  {
    dest[i] = source[i];
  }
  // strcpy(dest, source);
}

// Return 1 if the character code in c is a whitespace character,
// false otherwise.
//
// For the purposes of this function, a whitespace character is one of
//
//   ' '
//   '\t'
//   '\r'
//   '\n'
//   '\f'
//   '\v'
int wc_isspace(unsigned char c)
{
  return (c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == '\f' || c == '\v');
}

// Return 1 if the character code in c is an alphabetic character
// ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
int wc_isalpha(unsigned char c)
{
  if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))
  {
    return 1;
  }
  return 0;
}

// Read the next word from given input stream, storing
// the word in the array pointed-to by w. (This array should be
// assumed to be MAX_WORDLEN+1 elements in size.) Return 1
// if a word is read successfully, 0 otherwise.
//
// For the purposes of this function, a word is a sequence of
// 1 or more non-whitespace characters.
//
// If a sequence of non-whitespace characters has more than
// MAX_WORDLEN characters, then only the first MAX_WORDLEN
// characters in the sequence should be stored in the array.
int wc_readnext(FILE *in, unsigned char *w)
{
  int c;
  int len = 0;
  // Skip leading whitespace characters
  while ((c = fgetc(in)) != EOF && wc_isspace(c))
  {
    // Do nothing, just skip whitespace
  }
  while (c != EOF && !wc_isspace(c) && len < MAX_WORDLEN)
  {
    w[len] = c;
    len++;
    c = fgetc(in);
  }
  w[len] = '\0';
  // Check if a word was read successfully
  if (len > 0)
  {
    return 1; // Successfully read a word
  }
  else
  {
    return 0; // No word was read
  }
}

// Convert the NUL-terminated character string in the array
// pointed-to by w so that every letter is lower-case.
void wc_tolower(unsigned char *w)
{
  // TODO: implement
  int len = wc_strlen(w);
  for (int i = 0; i < len; i++)
  {
    if (w[i] >= 'A' && w[i] <= 'Z')
    {
      w[i] += 32; // adding by 32 changes it to lowercase in ascii
    }
  }
}

// Remove any non-alphabetic characters from the end of the
// NUL-terminated character string pointed-to by w.
void wc_trim_non_alpha(unsigned char *w)
{
  if (w == NULL)
    return;
  int k = wc_strlen(w) - 1;
  if (k == -1)
    return;
  while (k >= 0 && !wc_isalpha(w[k]))
  {
    k--;
  }
  w[k + 1] = '\0';
}

// Search the specified linked list of WordEntry objects for an object
// containing the specified string.
//
// If a matching object is found, set the int variable pointed-to by
// inserted to 0 and return a pointer to the matching object.
//
// If a matching object is not found, allocate a new WordEntry object,
// set its next pointer to point to what head points to (i.e., so the
// new object is at the head of the list), set the variable pointed-to
// by inserted to 1, and return a pointer to the new node. Note that
// the new node should have its count value set to 0. (It is the caller's
// job to update the count.)
struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted)
{
  struct WordEntry *itr;
  for (itr = head; itr != NULL; itr = itr->next)
  {
    if (wc_str_compare(itr->word, s) == 0)
    { // matching object found in LinkedList
      *inserted = 0;
      return itr;
    }
  }
  struct WordEntry *entry = malloc(sizeof(struct WordEntry));
  wc_str_copy(entry->word, s);
  entry->count = 0;
  entry->next = head;
  *inserted = 1;
  return entry;
}

// Find or insert the WordEntry object for the given string (s), returning
// a pointer to it. The head of the linked list which contains (or should
// contain) the entry for s is the element of buckets whose index is the
// hash code of s mod num_buckets.
//
// Returns a pointer to the WordEntry object in the appropriate linked list
// which represents s.
struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s)
{
  int index = wc_hash(s) % num_buckets;
  int inserted;
  buckets[index] = wc_find_or_insert(buckets[index], s, &inserted);
  return buckets[index];
}

// Free all of the nodes in given linked list of WordEntry objects.
void wc_free_chain(struct WordEntry *p)
{
  struct WordEntry *itr = p;
  struct WordEntry *prev = NULL;
  while (itr != NULL)
  {
    prev = itr;
    itr = itr->next;
    free(prev);
  }
}

int wc_strlen(const unsigned char *s)
{
  int size = 0;
  const unsigned char *itr = s;
  while (*itr != '\0')
  {
    itr++;
    size++;
  }
  return size;
}