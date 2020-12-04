#!/usr/bin/env python

import argparse
import os
import pathlib
import shutil
import subprocess

resolutions = {
    'ldpi': 36,
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
}

aparser = argparse.ArgumentParser()
aparser.add_argument('-p', '--prefix', help='res/{prefix}-{size}', default='drawable')
aparser.add_argument('-b', '--basename', help='use a different filename than the original')
aparser.add_argument('infile', help='icon to convert')
aparser.add_argument('outdir', help='Android Studio resource directory to place files in')
aparser.add_argument('-c', '--clobber', help='Clobber any existing files', default=False, action='store_true')

args = aparser.parse_args()

for friendly, raw_value in resolutions.items():
    raw_str = str(raw_value)
    infile = pathlib.Path(args.infile)
    outfile = pathlib.Path(args.outdir) / f'{args.prefix}-{friendly}'
    print(f'{infile} -> {outfile}')

    if args.basename:
        outfile /= f'{args.basename}.png'
    else:
        outfile /= f'{infile.stem}.png'

    if not outfile.parent.exists():
        os.makedirs(outfile.parent)

    if outfile.exists() and not args.clobber:
        print("\tFile exists, skipping...")
        continue

    subprocess.call(['inkscape',
        '-w', str(raw_value),
        '-w', str(raw_value),
        '-o', outfile,
        infile
    ])
