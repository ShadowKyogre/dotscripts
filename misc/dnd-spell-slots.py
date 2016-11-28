#!/usr/bin/env python3

from argparse import ArgumentParser

def caster_slots(level):
    slots = [2, 0, 0, 0, 0, 0, 0, 0, 0]
    slots[0] += min(level, 3) - 1

    if level >= 3:
        slots[1] += min(level, 4) - 1

    if level >= 5:
        slots[2] += min(level, 6) - 3

    if level >= 7:
        slots[3] += min(level, 9) - 6

    if level >= 9:
        slots[4] += int((min(level, 18)-2) / 8) + 1

    if level >= 11:
        slots[5] += int((min(level, 19)-3) / 8)

    if level >= 13:
        slots[6] += int((min(level, 20)-3) / 8)

    if level >= 15:
        slots[7] = 1

    if level >= 17:
        slots[8] = 1

    return slots

aparser = ArgumentParser()
aparser.add_argument('-l', '--level', help='Print level only', action='store_true')
aparser.add_argument('full_caster', type=int, default=0)
aparser.add_argument('half_caster', type=int, default=0, nargs='?')
aparser.add_argument('third_caster', type=int, default=0, nargs='?')

args = aparser.parse_args()

spellcaster_levels = (
    args.full_caster
    + int(args.half_caster / 2)
    + int(args.third_caster / 3)
)

if args.level:
    print(spellcaster_levels)
    exit(0)

slots = [0, 0, 0, 0, 0, 0, 0, 0, 0]

lv20s, others = divmod(spellcaster_levels, 20)

for i in range(lv20s):
    slots = [x + y for x, y in zip(slots, caster_slots(20))]

if others > 0:
    slots = [x + y for x, y in zip(slots, caster_slots(others))]

print(slots)

