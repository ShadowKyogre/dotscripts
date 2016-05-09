import sqlite3
import json
import urllib.parse as urlparse
import sys
import datetime

# you know, I should post this in a gist

jsonexpt={
	"bookmarks":[],
	"folders":[],
}

if len(sys.argv) == 2:
	with sqlite3.connect(sys.argv[1]) as db:
		db.row_factory = sqlite3.Row
		c = db.cursor()
		get_parent_c = db.cursor()

		for row in c.execute('SELECT * from bookmarks'):
			#print(row, type(row))
			if row['is_folder'] == 0:
				bkobj={}
				bkobj["visitedDate"]=int(row['date'] / 1000)
				bkobj["creationDate"]=int(row['created'] / 1000)
				bkobj["visits"]=row['visits']
				bkobj["url"]=urlparse.quote(row['url'])
				bkobj["title"]=urlparse.quote(row['title'])
				if row['parent_crc_id'] == 0:
					bkobj["folderId"]=-1
				else:
					#print(row['parent_crc_id'])
					get_parent_c.execute('SELECT * from bookmarks WHERE crc_id=?', (row['parent_crc_id'],))
					prow = get_parent_c.fetchone()
					bkobj["folderId"]=int(prow['_id'])
				jsonexpt["bookmarks"].append(bkobj)

			else:
				bkobj={}
				bkobj["title"]=urlparse.quote(row['title'])
				if row['parent_crc_id'] == 0:
					bkobj["parentId"]=-1
				else:
					get_parent_c.execute('SELECT * from bookmarks WHERE crc_id=?', (row['parent_crc_id'],))
					prow = get_parent_c.fetchone()
					bkobj["parentId"]=int(prow['_id'])
				bkobj["title"]=urlparse.quote(row['title'])
				bkobj["id"]=int(row['_id'])
				jsonexpt["folders"].append(bkobj)

	with open(sys.argv[1].replace("db","json"), 'w', encoding='utf-8') as wf:
		json.dump(jsonexpt, wf)
