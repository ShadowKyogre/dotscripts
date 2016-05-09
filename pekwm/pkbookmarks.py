#!/usr/bin/env python2
import sqlite3
from xml.sax.saxutils import quoteattr

import shutil
import tempfile

browser = 'firefox'
ffsqlite= '/home/shadowkyogre/.mozilla/firefox/1fo88b8i.default/places.sqlite'

def print_label(title, url):
	print 'Entry = %s { Actions =\"Exec %s \\"%s\\"\" }'  % (quoteattr(title.encode('utf-8')), browser, url.encode('utf-8'))
#echo "Entry = \"$name\" { Actions =\"Exec exo-open $line &\" }"

def rbuild_tree(id, title, conn, first_run=False):
		if first_run:
			print 'Dynamic {'
		else:
			print 'Submenu = %s {' % (quoteattr(title.encode('utf-8')))

		c2 = conn.cursor()
		c2.execute('select id, title, type from moz_bookmarks b where parent=? and type=2;', (id, ))
		for sid, stitle, type in c2:
			rbuild_tree(sid, stitle, conn)
		c2.execute('select b.title, p.title, p.url from moz_bookmarks b, moz_places p where b.fk = p.id and b.type=1 and parent=?;', (id, ))
		for btitle, ptitle, url in c2:
			if url == None or url.startswith('place'):
				continue
			if btitle != None:
				print_label(btitle, url)
			else:
				print_label(btitle, url)

		if first_run:
			print '}'
		else:
			print '}'

def main():

	tf = tempfile.NamedTemporaryFile('r', suffix='.sqlite')

	shutil.copyfile(ffsqlite, tf.name)
	conn = sqlite3.connect(tf.name)

	rbuild_tree(2, '', conn, True)

	conn.close()
	tf.close()

if __name__ == '__main__':
	main()
