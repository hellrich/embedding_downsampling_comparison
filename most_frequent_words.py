from __future__ import print_function
from docopt import docopt
import random
from collections import defaultdict

if __name__ == "__main__":
    args = docopt("""
        Usage:
            most_frequent_words.py <n> <file_name>
    """)
    n = int(args["<n>"])
    file_name = args["<file_name>"]
    words = defaultdict(int)

    with open(file_name) as f:
        for line in f:
            for word in line.split():
                words[word] += 1

    top_words = sorted(words.keys(), key=lambda k: words[k], reverse=True)[:n]
    for word in top_words:
        print(word)
