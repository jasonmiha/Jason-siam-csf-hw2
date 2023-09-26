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
  struct WordEntry *buckets[HASHTABLE_SIZE] = {NULL};

  if (argc == 1)
  {
    unsigned char word[MAX_WORDLEN + 1];
    while (wc_readnext(stdin, word) == 1)
    {
      total_words++;
      wc_tolower(word);
      wc_trim_non_alpha(word); // stuff like '13' or '?./' get converted to empty strings, which do count towards wordcount and only once towards unique count
      struct WordEntry *wordEntry = wc_dict_find_or_insert(buckets, HASHTABLE_SIZE, word);
      wordEntry->count++;
    }
    // scan in everything from stdin
    // fp = fopen(stdin, "r");
  }
  else if (argc >= 2)
  {
    // open from the file name.
    FILE *fp = fopen(argv[1], "rb");
    if (fp == NULL)
    {
      fprintf(stderr, "Could not open file. Please try again!\n");
      return 2;
    }
    unsigned char word[MAX_WORDLEN + 1];
    while (wc_readnext(fp, word) == 1)
    {
      total_words++;
      wc_tolower(word);
      wc_trim_non_alpha(word);
      struct WordEntry *wordEntry = wc_dict_find_or_insert(buckets, HASHTABLE_SIZE, word);
      // if (wordEntry->count == 0) { // its only 0 if its just newly added
      //   unique_words++;
      // }
      if (wordEntry->count == 0) {
        // printf("Word: %s\n", wordEntry->word);
        // unique_words++;
      }
      wordEntry->count++;
    }
    fclose(fp);
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
        itr = itr->next;
        unique_words++;
      }
    }
  }
  printf("Total words read: %u\n", (unsigned int)total_words);
  printf("Unique words read: %u\n", (unsigned int)unique_words);
  printf("Most frequent word: %s (%u)\n", (const char *)best_word, best_word_count);

  // make sure memory is freed
  for (int i = 0; i < HASHTABLE_SIZE; i++)
  {
    if (buckets[i] != NULL)
    {
      wc_free_chain(buckets[i]);
    }
  }
  return 0;
}

// TODO: definitions of helper functions
