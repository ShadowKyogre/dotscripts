import csv
import json
import urllib.parse as urlparse
import sys
import datetime

jsonexpt={
	"bookmarks":[],
	"folders":[],
}

if len(sys.argv) == 2:
	with open(sys.argv[1]) as f:
		csvr = csv.reader(f, delimiter="\t")

		for row in csvr:

			if row[2] == "0":
				bkobj={}
				bkobj["visitedDate"]=int(datetime.datetime.now().timestamp())
				bkobj["creationDate"]=int(datetime.datetime.now().timestamp())
				bkobj["visits"]=1
				bkobj["url"]=urlparse.quote(row[1])
				bkobj["title"]=urlparse.quote(row[0])
				if row[3] == "1":
					bkobj["folderId"]=-1
				else:
					bkobj["folderId"]=int(row[3])
				jsonexpt["bookmarks"].append(bkobj)

			elif row[4] != "1":
				bkobj={}
				bkobj["title"]=urlparse.quote(row[0])
				if row[3] == "1":
					bkobj["parentId"]=-1
				else:
					bkobj["parentId"]=int(row[3])
				bkobj["title"]=urlparse.quote(row[0])
				bkobj["id"]=int(row[4])
				jsonexpt["folders"].append(bkobj)

	with open(sys.argv[1].replace("tsv","json"), 'w', encoding='utf-8') as wf:
		json.dump(jsonexpt, wf)
