#include <stdio.h>
#include <stdint.h>
#include "wcfuncs.h"

// Suggested number of buckets for the hash table
#define HASHTABLE_SIZE 13249

int main(int argc, char **argv)
{
  // stats (to be printed at end)
  uint32_t total_words = 0;
  uint32_t unique_words = 0;
  const unsigned char *best_word = (const unsigned char *)"";
  uint32_t best_word_count = 0;
  FILE *fp = fopen(argv[1], "rw");
  struct WordEntry *buckets[HASHTABLE_SIZE] = {NULL};

  unsigned char word[MAX_WORDLEN + 1];
  while (wc_readnext(fp, word) == 1)
  {
    total_words++;
    wc_tolower(word);
    wc_trim_non_alpha(word);
    wc_dict_find_or_insert(buckets, HASHTABLE_SIZE, word)->count++;
  }

  for (int i = 0; i < HASHTABLE_SIZE; i++)
  {
    struct WordEntry *itr;
    if (buckets[i] != NULL)
    {
      itr = buckets[i];
      while (itr != NULL)
      {
        if (itr->count > best_word_count)
        {
          best_word_count = itr->count;
          best_word = itr->word;
        }
        else if (itr->count == best_word_count && wc_str_compare(itr->word, best_word) < 0)
        {
          best_word = itr->word;
        }
        unique_words++;
        itr = itr->next;
      }
    }
  }
  printf("Total words read: %u\n", (unsigned int)total_words);
  printf("Unique words read: %u\n", (unsigned int)unique_words);
  printf("Most frequent word: %s (%u)\n", (const char *)best_word, best_word_count);

  // make sure file is closed (if one was opened)
  fclose(fp);
  // make sure memory is freed
  for (int i = 0; i < HASHTABLE_SIZE; i++) {
    if (buckets[i] != NULL) {
      wc_free_chain(buckets[i]);
    }
  }
  return 0;
}

// TODO: definitions of helper functions
