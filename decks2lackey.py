#!/usr/bin/python

import os
import argparse
import csv
import sqlite3
import re

db = None

def YVD2Lackey(deck, out="."):
	basename=os.path.basename(os.path.splitext(deck)[0])
	outfile=open(os.path.join(out,"{}.txt".format(basename)),'w')
	oldfile=open(deck, 'r', encoding="utf-8")
	sideboard_lines=[]
	main_lines=[]
	extra_lines=[]

	#we need this to distinguish between normal monsters and extra monsters
	set_path = os.path.abspath("{}/../../yvd.set".format(deck))
	with open(set_path,'r',encoding="latin-1") as card_db:
		global db
		if db is None:
			fnames = ('name',
				'number',
				'pack',
				'type',
				'attr',
				'level',
				'spell-type',
				'atk',
				'def',
				'text'
				)
			
			pad_fnames=['s']
			pad_fnames.extend(fnames)

			con = sqlite3.connect(":memory:")
			cur = con.cursor()
			cur.execute(("CREATE TABLE t (name, number, pack, type, attr, "
						"level, idkwhatthisis, atk, def, text);"))
			tmpdb = csv.DictReader(card_db,fieldnames=pad_fnames, delimiter="|")
			to_db = [tuple(c[k] for k in fnames) for c in tmpdb]
			print(to_db[0])
			
			cur.executemany(("INSERT INTO t (name, number, pack, type, attr, "
						"level, idkwhatthisis, atk, def, text) "
						"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"), to_db)
			con.commit()

	goes_in_extra = re.compile(r'Synchro|Xyz|Fusion')
	side=False
	for r in oldfile:
		if r == '-SIDE DECK-\n':
			side=True
			continue
		row=r.split('|')
		print(row[2][:-1])
		cur.execute('SELECT * from t WHERE name=?',[row[2][:-1]])
		db_data = cur.fetchone()
		print(db_data)
		if not side:
			if goes_in_extra.search(db_data[3]) is not None:
				extra_lines.append("{}\t{}".format(row[0],row[2]))
			else:
				main_lines.append("{}\t{}".format(row[0],row[2]))
		else:
			sideboard_lines.append("{}\t{}".format(row[0],row[2]))
	
	lines=main_lines+['Extra:\n']+extra_lines+['Side Deck:\n']+sideboard_lines
	outfile.writelines(lines)
	oldfile.close()
	outfile.close()

def MWS2Lackey(deck, out="."):
	basename=os.path.basename(os.path.splitext(deck)[0])
	outfile=open(os.path.join(out,"{}.txt".format(basename)),'w')
	oldfile=open(deck, 'r', encoding="utf-8")
	sideboard_lines=[]
	main_lines=[]
	data=re.compile(r"(.{4})(\d+) \[[A-Z0-9]{2,}\] (.*)")
	excess_number=re.compile(r" \(\d+\)$")
	
	deck_data=oldfile.read()
	card_data = data.findall(deck_data)
	for c in card_data:
		if c[0] == "SB: ":
			sideboard_lines.append("{}\t{}\n".format(
				c[1],excess_number.sub("",c[2])))
		else:
			main_lines.append("{}\t{}\n".format(
				c[1],excess_number.sub("",c[2])))
	
	lines=main_lines+['Sideboard:\n']+sideboard_lines
	outfile.writelines(lines)
	oldfile.close()
	outfile.close()

if __name__ == "__main__":
	parser = argparse.ArgumentParser(prog='decks2lackey', description="Convert other decks to LackeyCCG deck format!")
	parser.add_argument('decks', metavar='N', type=str, nargs='+',
						help='decks to process')
	parser.add_argument('-d','--directory', help='Save the file in this directory', default=".")

	args = parser.parse_args(os.sys.argv[1:])
	files = []

	for d in args.decks:
		ext = os.path.splitext(d)[1]

		#YVD formatting...ugph
		if ext == '.dek' and os.path.abspath("{}/../..".format(d)).find("Yugioh Virtual Dueling"):
			YVD2Lackey(d, out=args.directory)
		#MWS formatting
		elif ext == '.mwdeck':
			MWS2Lackey(d, out=args.directory)
