#!/usr/bin/python2

from lxml import html,etree
from collections import OrderedDict as od
import argparse
import os
import urllib2

BLOCKS=od([
	('Portal',[
		'Portal',
		'Portal Second Age',
		'Portal Three Kingdom',
	]),
	('Humor Editions',[
		'Unglued',
		'Unhinged',
	]),
	('Starter',[
		'Starter',
		'Starter 2000',
	]),
	('Reeditions',[
		'Anthologies',
		'Battle Royale',
		'Beatdown',
		'Chronicles',
		'Deck Masters',
	]),
	('Base Sets',[
		'Alpha',
		'Beta',
		'Unlimited',
		'Revised',
		'4th Edition',
		'5th Edition',
		'6th Edition',
		'7th Edition',
		'8th Edition',
		'9th Edition',
		'10th Edition',
		'Core Set - Magic 2010',
		'Core Set - Magic 2011',
		'Core Set - Magic 2012',
	]),
	('Duel Decks',[
		'Duel Decks: Elf Vs Goblin',
		'Duel Decks: Jace Vs Chandra',
		'Duel Decks: Divine Vs Demonic (DVD)',
		'Duel Decks: Garruk vs Liliana (DDD)',
		'Duel Decks: Phyrexia vs The Coalition (DDE)',
		'Duel Decks: Elspeth vs Tezzeret (DDF)',
		'Duel Decks: Knights vs Dragons - LowQuality',
		'Duel Decks: Ajani vs Nicol Bolas (DDH)',
	]),
	('From The Vault',[
		'From The Vault: Dragons(DRB)',
		'From The Vault: Exiled(FVE)',
		'From The Vault: Relics(V10)',
		'From The Vault: Legends(LEG) - Low Quality',
	]),
	('Special Editions',[
		'Vanguard (VG or VGD)',
		'Vanguard MOL (VGM)',
		'Vanguard Online Avatars (VOA)', #text for link
		'Planechase',
		'Planechase - Planes',
		'Magic - Commander (CMD)'
	]),
# Expansion Booster Packs #
	('Mirrodin Block',[
		'Mirrodin',
		'Darksteel',
		'Fifth Dawn',
	]),
	('Kamigawa Block',[
		'Kamigawa',
		'Betrayers of Kamigawa',
		'Saviors of Kamigawa',
	]),
	('Ravnica Block',[
		'Ravnica',
		'Guildpact',
		'Dissension',
	]),
	('Lorwin Mini-Block',[
		'Lorwin',
		'Morningtide',
	]),
	('Eventide Mini-Block',[
		'Shadowmoor',
		'Eventide',
	]),
	('Alara Block',[
		'Shards of Alara',
		'Conflux',
		'Alara Reborn',
	]),
	('Zendikar Block',[
		'Zendikar',
		'Worldwake',
		'Rise of the Eldrazi',
	]),
	('Scars Block',[
		'Scars of Mirrodon',
		'Mirrodon Besieged',
		'New Phyrexia',
	]),
	('Innistrad Block',[
		'Innistrad',
		'Dark Acension',
	]),
])

l=BLOCKS.values()
SETLIST=[]
for item in l:
	SETLIST.extend(item)

def download_mediafire_link(url):
	find_url=html.parse(url)
	here=find_url.xpath("//div[@class='download_link']/a")[0]
	print ("Downloading {}".format(here.attrib['href']))

	downloadpath=os.path.basename(here.attrib['href'])
	if os.path.exists(save_folder):
		downloadpath=os.path.join(save_folder,downloadpath)
	print ("Saving to {}".format(downloadpath))

	newfile = open(downloadpath,'w')

	response = urllib2.urlopen(here.attrib['href'])
	newfile.write(response.read())

	response.close()
	newfile.close()

def download_block(block):
	data=MTGBR_PAGE.xpath("//td[text()='{}']".format(block))
	if len(data) == 0:
		print("Unable to find block {}".format(block))
		return
	data=data[0]
	root=data.getparent().getparent().getparent()
	needed_links=root.xpath(".//tr/td/a")
	for link in needed_links:
		download_mediafire_link(link.attrib['href'])
	#print needed_links
	#print etree.tostring(root)
	print("Done downloading block {}".format(block))

def download_pack(pack):
	data=MTGBR_PAGE.xpath("//img[@alt='{pack}']|//alt[text()='{pack}']".format(**locals()))
	if len(data) == 0:
		return
	data=data[0]
	if data.tag == 'img':
		url=data.getparent().attrib['href']
	else:
		url=data.attrib['href']
	download_mediafire_link(url)
	print("Done downloading pack {}".format(pack))

if __name__ == "__main__":
	parser = argparse.ArgumentParser(prog='mtgbr_downloader',description="Download card images from mtgbr.com")
	parser.add_argument('-b','--block', help='Download the specified block.',nargs='+',choices=BLOCKS.keys())
	parser.add_argument('-p','--pack', help='Download the specified pack.',nargs='+',choices=SETLIST)
	parser.add_argument('-m','--mode',help='Whether to download the cropped versions or not',choices=['crop','full'],default='crop')
	parser.add_argument('-l','--lang',help='Language to download the full page in (if not USA)',choices=['it','sko','jp','ru','fr','esp','de','cn','br'])
	parser.add_argument('-d','--directory',help='Save the file in this directory',default=".")
	args = parser.parse_args(os.sys.argv[1:])

	global save_folder
	save_folder=args.directory
	#print(args)

	if args.block is None and args.pack is None:
		print("No packs or blocks given, assuming the task is to download all packs...")

	if args.mode == 'crop':
		get_url="http://mws.mtgbr.com/crop-01.htm"
	else:
		if args.lang > '':
			get_url="http://mws.mtgbr.com/full-01{}.htm".format("-{lang}".format(**locals()))
		else:
			get_url="http://mws.mtgbr.com/full-01.htm"

	try:
		global MTGBR_PAGE
		MTGBR_PAGE=html.parse(get_url)
	except Exception,e:
		print e

	if args.block is not None:
		for block in args.block:
			print("Downloading block {}".format(block))
			download_block(block)
			print("")

	if args.pack is not None:
		for pack in args.pack:
			print("Downloading pack {}".format(pack))
			download_pack(pack)
			print("")