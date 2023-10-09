#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "wcfuncs.h"

#define HASHTABLE_SIZE 50000000 // setting size to this allows correct output in the little_dorrit file

int main(int argc, char **argv)
{
  // stats (to be printed at end)
  uint32_t total_words = 0;
  uint32_t unique_words = 0;
  const unsigned char *best_word = (const unsigned char *)"";
  uint32_t best_word_count = 0;

  // for (int i = 0; i < HASHTABLE_SIZE; i++) {
  //   buckets[i] = NULL;
  // }

  FILE *fp;
  if (argc == 1)
  {
    fp = stdin;
  }
  else if (argc >= 2)
  {
    fp = fopen(argv[1], "r");
    if (fp == NULL)
    {
      fprintf(stderr, "Could not open file. Please try again!\n");
      return 2;
    }
  }
  struct WordEntry ** buckets = malloc(sizeof(struct WordEntry*) * HASHTABLE_SIZE);

  unsigned char word[MAX_WORDLEN + 1];
  while (wc_readnext(fp, word) == 1)
  {
    total_words++;
    wc_tolower(word);
    wc_trim_non_alpha(word);
    struct WordEntry *entry = wc_dict_find_or_insert(buckets, HASHTABLE_SIZE, word);
    if (entry->count == 0)
    {
      unique_words++;
    }
    entry->count++;
    if (entry->count > best_word_count)
    {
      best_word_count = entry->count;
      best_word = entry->word;
    }
    else if (entry->count == best_word_count && wc_str_compare(entry->word, best_word) < 0)
    {
      best_word = entry->word;
    }
  }

  printf("Total words read: %u\n", (unsigned int)total_words);
  printf("Unique words read: %u\n", (unsigned int)unique_words);
  printf("Most frequent word: %s (%u)\n", (const char *)best_word, best_word_count);

  for (int i = 0; i < HASHTABLE_SIZE; i++)
  {
    if (buckets[i] != NULL)
    {
      wc_free_chain(buckets[i]);
    }
  }

  free(buckets);

  if (argc >= 2)
  {
    fclose(fp);
  }
  
  return 0;
}