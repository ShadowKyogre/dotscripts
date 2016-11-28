#!/usr/bin/env python3

from argparse import ArgumentParser

def pb_to_stat(val):
    if val <= 5:
        return val
    elif val == 7:
        return 6
    elif val == 9:
        return 7
    else:
        raise ValueError("Invalid point buy cost: {0}".format(val))

aparser = ArgumentParser()
aparser.add_argument('cost', type=int, default=0, nargs='?')

args = aparser.parse_args()
print(pb_to_stat(args.cost))
