#!/usr/bin/env python2

from lxml import html,etree
from collections import OrderedDict as od
import argparse
import os
import urllib, urllib2, cookielib
import getpass
from lxml.html import soupparser
import re

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))

def login(args):
	global username
	if args.user is None:
		username=raw_input('Please type your username: ')
	else:
		username=args.user
	password=getpass.getpass('Enter your password: ')
	login_data = urllib.urlencode({'username' : username, 'password' : password, 'remember_me':1})
	opener.open('https://www.deviantart.com/users/login', login_data)

def get_deviation(dev_link, args):
	global username
	resp = opener.open(dev_link)
	print "Opened {}".format(dev_link)
	dev_page = soupparser.fromstring(resp.read())
	strip_this="{} on deviantART".format(username)
	title=re.sub(" by .{}$".format(strip_this),"",dev_page.xpath('//title')[0].text)
	print "Title is {}".format(title)
	if dev_page.cssselect(".journalcontrol") and args.journal:
		print "Saving journal"
		strip_this="{} on deviantART".format(username)
		title=re.sub(" by .{}$".format(strip_this),"",dev_page.xpath('//title')[0].text)
		pathy=os.path.basename(os.path.dirname(dev_link))
		save_here=os.path.join(args.directory,title+"_-_"+pathy+".html")
		if not os.path.exists(save_here):
			f=open(save_here,'wb')
			f.write(etree.tostring(dev_page.cssselect(".journalcontrol")[0]))
			f.close()
	if dev_page.cssselect("#zoomed-in") and args.deviations:
		print "Saving image"
		dev_download=dev_page.cssselect("#download-button")
		save_here=os.path.join(args.directory,os.path.basename(dev_download[0].attrib['href']))
		if not os.path.exists(save_here):
			f=open(save_here,'wb')
			response = urllib2.urlopen(dev_download[0].attrib['href'])
			f.write(response.read())
			f.close()
	if dev_page.cssselect("#lit-view") and args.deviations:
		print "Saving Story"
		dev_download=dev_page.cssselect("#download-button")
		save_here=os.path.join(args.directory,os.path.basename(dev_download[0].attrib['href']))
		if not os.path.exists(save_here):
			f=open(save_here,'wb')
			response = urllib2.urlopen(dev_download[0].attrib['href'])
			f.write(response.read())
			f.close()
	if dev_page.cssselect('#artist-comments') and args.text:
		print "Saving description"
		#dev_page.xpath('//title')[0].text
		# by ~<username> on deviantART
		pathy=os.path.basename(os.path.dirname(dev_link))
		save_here=os.path.join(args.directory,title+"_-_"+pathy+"_-_description.html")
		if not os.path.exists(save_here):
			f=open(save_here,'wb')
			f.write(etree.tostring(dev_page.cssselect("#artist-comments")[0]))
			f.close()
	#class="journalcontrol" indicates we have journal
	#id="zoomed-in" indicates we have picture
	#id="lit-view" indicates we have story
	#id="artist-comments" has the artist comment information
	#id="download-button" contains the link we need to download, which is for pics and lit only
	print "Downloaded all of {}".format(dev_link)

def get_journals(args):
	resp = opener.open('http://my.deviantart.com/journal/?offset=0')
	print "Opened your dA journal management page"
	got_all_journals=False
	dev_page = soupparser.fromstring(resp.read())
	while not got_all_journals:
		for journal in dev_page.xpath("//ul[@class='f list']/li/a"):
			#dev_link_date=dev.xpath('./td')[3]
			#print dev_link_cell.attrib['href']
			print etree.tostring(journal)
			try:
				get_deviation(journal.attrib['href'],args)
			except IndexError:
				print ("Probably tried to get a deviation that"
				" didn't have download of the original enabled")
		next_page=dev_page.cssselect('.pagination ul.pages li.next a')
		if not ('href' in next_page[0].attrib.keys()):
			got_all_journals=True
		else:
			print "proceeding to {}".format(next_page[0].attrib['href'])
			resp=opener.open('http://my.deviantart.com{}'.format(next_page[0].attrib['href']))
			dev_page = soupparser.fromstring(resp.read())

def get_deviations(args):
	resp = opener.open('http://my.deviantart.com/gallery/?offset=0')
	print "Opened your dA gallery management page"
	got_all_devs=False
	dev_page = soupparser.fromstring(resp.read())
	print dev_page.xpath('//tbody')
	#print dev_page.getchildren('tbody')
	while not got_all_devs:
		for dev in dev_page.xpath('//tbody/tr'):
			dev_link_cell=dev.xpath('./td/a')[0]
			#dev_link_date=dev.xpath('./td')[3]
			#print dev_link_cell.attrib['href']
			#print etree.tostring(dev_link_cell)
			try:
				get_deviation(dev_link_cell.attrib['href'],args)
			except IndexError:
				print ("Probably tried to get a deviation that"
				" didn't have download of the original enabled")
		next_page=dev_page.cssselect('.pagination ul.pages li.next a')
		if not ('href' in next_page[0].attrib.keys()):
			got_all_devs=True
		else:
			print "proceeding to {}".format(next_page[0].attrib['href'])
			resp=opener.open(next_page[0].attrib['href'])
			dev_page = soupparser.fromstring(resp.read())

if __name__ == "__main__":
	parser = argparse.ArgumentParser(prog='dApuller',description="Download all of your data from dA")
	#parser.add_argument('-f','--folders', help='Download the specified block.',nargs='+')
	#is this really necessary?
	parser.add_argument('-u','--user', help='Download the specified user\'s deviations.')
	#parser.add_argument('-n','--notes',help='Include the user\'s notes too', default=False, action='store_true')
	#unsure of how to save notes since it's fully dependent on javascript
	parser.add_argument('-t','--text',help='Include the description too', default=False, action='store_true')
	parser.add_argument('-s','--timestamp',help='Include the timestamp too', default=False, action='store_true')
	parser.add_argument('-v','--deviations',help='Include the deviations too', default=False, action='store_true')
	parser.add_argument('-j','--journal', help="Download this user's journals too.", default=False, action='store_true')
	parser.add_argument('-d','--directory',help='Save the files in this directory',default=".")
	args = parser.parse_args(os.sys.argv[1:])
	login(args)
	if args.deviations:
		get_deviations(args)
	if args.journal:
		get_journals(args)
