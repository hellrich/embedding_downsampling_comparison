from __future__ import print_function
from docopt import docopt
import random
from collections import defaultdict


#iterates twice over input, result needs to be shuffled!

if __name__ == "__main__":
    args = docopt("""
        Usage:
            bootstrap.py <file_name>
    """)
    file_name = args["<file_name>"]
    lines = 0
    with open(file_name) as f:
       for line in f:
           lines += 1

    to_sample = {random.randrange(0, lines) for i in range(0,lines)}

    lines = 0
    with open(file_name) as f:
        for line in f:
            if lines in to_sample:
                print(line, end='')
            lines += 1
