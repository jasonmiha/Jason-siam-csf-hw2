#include <stdio.h>
#include <stdint.h>
#include "wcfuncs.h"

// Suggested number of buckets for the hash table
#define HASHTABLE_SIZE 13249

// TODO: prototypes for helper functions

int main(int argc, char **argv)
{
  // stats (to be printed at end)
  uint32_t total_words = 0;
  uint32_t unique_words = 0;
  const unsigned char *best_word = (const unsigned char *)"";
  uint32_t best_word_count = 0;
  // printf("Halelsaldsafkslknfdsfsdklnfsdfk\n");
  FILE *fp = fopen("jason.txt", "rw");
  // printf("jdksbfjdsdbfjhgdbsjhfbdsjhfhg\n");
  struct WordEntry *buckets[HASHTABLE_SIZE] = {NULL};
  // printf("ifhdsfisdhflidhslfihn\n");
  // TODO: implement
  /* while ( next word is read successfully using wc_readnext ) {
  increase total word count by 1

  use wc_tolower to convert word to lower case

  use wc_trim_non_alpha to remove non-alphabetic characters at end of word

  use wc_dict_find_or_insert to find or insert the word in the hash table

  increment the WordEntry's count
}*/
  // printf("dsbfndsbfjdsabfjhsdbc sdc\n");

  unsigned char word[MAX_WORDLEN + 1];
  while (wc_readnext(fp, word) == 1)
  {
    // our readnext function cannot handle double spaces. figure out a way to terminate all double spaces between words.
    // printf("ifhdsfisfsdfds as fsf sdf sddhflidhslfihn\n");

    total_words++;
    wc_tolower(word);
    wc_trim_non_alpha(word);
    wc_dict_find_or_insert(buckets, HASHTABLE_SIZE, word)->count++;
  }

  /*In finding the unique word with the highest number of occurrences, you will need to traverse the entire hash table
  (i.e., scan through every WordEntry object in every bucket of the hash table.)
  One situation that could arise is that there could be multiple WordEntry objects that are tied for the highest occurrence count.
  In this case, choose the candidate (among the words with the highest occurrence count)
  that compares as least lexicographically as the one to display when the summary stats are printed.
  You can use the wc_str_compare function to do lexicographical comparisons of strings.*/
  unsigned char bestWord[MAX_WORDLEN + 1];
  for (int i = 0; i < HASHTABLE_SIZE; i++)
  {
    struct WordEntry *itr;
    // printf("======= i = [%u] =======\n", i);
    if (buckets[i] != NULL)
    {
      // printf("itr is not null at i = %u\n", i);
      itr = buckets[i];
      while (itr != NULL)
      {
        // printf("itr is %s\n", itr->word);
        if (itr->count > best_word_count)
        {
          // printf("itr count is better than word count, [%u >= %u]\n", itr->count, best_word_count);
          best_word_count = itr->count;
          // printf("this is before the strcopy\n");
          // wc_str_copy(bestWord, itr->word);
          best_word = itr->word;
        }
        else if (itr->count == best_word_count && wc_str_compare(itr->word, best_word) < 0)
        {
          // printf("itr count is EQUAL to word count, [%u == %u]\n", itr->count, best_word_count);
          // wc_str_copy(bestWord, itr->word);
          best_word = itr->word;
          // continue;
        }
        unique_words++;
        // printf("setting itr to next\n");
        itr = itr->next;
      }
    }
  }
  // best_word = bestWord;
  printf("Total words read: %u\n", (unsigned int)total_words);
  printf("Unique words read: %u\n", (unsigned int)unique_words);
  printf("Most frequent word: %s (%u)\n", (const char *)best_word, best_word_count);

  // TODO: make sure file is closed (if one was opened)
  fclose(fp);
  // TODO: make sure memory is freed

  return 0;
}

// TODO: definitions of helper functions
