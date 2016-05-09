#!/usr/bin/env python3

import fontforge

import argparse
import glob
import os

aparser = argparse.ArgumentParser(prog='imgdir2sfd', description='Converts a dir of font rasters to an sfd')
aparser.add_argument('imgs_dir')
aparser.add_argument('output_sfd')
aparser.add_argument('--simplify', action='store_true', default=False)
args = aparser.parse_args()

n = fontforge.font()

for item in glob.glob(os.path.join(args.imgs_dir, '*')):
	glyph_name = os.path.basename(os.path.splitext(item)[0])
	slot = n.findEncodingSlot(glyph_name)
	n.createChar(slot, glyph_name)
	n[glyph_name].importOutlines(item)
	n[glyph_name].autoTrace()
	if args.simplify:
		n[glyph_name].simplify()

n.save(args.output_sfd)
