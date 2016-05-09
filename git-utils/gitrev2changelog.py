#!/usr/bin/env python
import subprocess
import re
import sys
from datetime import datetime
from collections import OrderedDict as od
import argparse

commit_data=re.compile((r'commit[ ]*([0-9a-f]*)\n'
r'Author:[ ]*([^\n]*)\n'
r'Date:[ ]*([^\n]*)\n{2}'
r'([ ]+[^\n]*\n)*\n?'))
tag=re.compile(r'\(tag: ([^\)]*)\){1}')

def write_tagged_changelog(single_user=False, verbose=False):
	tags = subprocess.check_output(['git', 'log', '--simplify-by-decoration',
					 '--decorate', '--pretty=oneline'])
	tags = tags.decode(sys.getdefaultencoding())
	tags = tag.findall(tags)
	tags.reverse()
	log_by_tag=od([])
	for t in range(len(tags)-1,-1,-1):
		tag_to_write=tags[t]
		if t == 0:
			between = tags[t]
		else:
			between = "{}..{}".format(tags[t-1],tags[t])
		if verbose:
			sys.stderr.write('Getting commit data for tag range {}\n'.format(between))
		if tag_to_write not in log_by_tag.keys():
			log_by_tag[tag_to_write]={}
			if not single_user:
				log_by_tag[tag_to_write]['authors']=set([])
			log_by_tag[tag_to_write]['changes']=[]
			log_by_tag[tag_to_write]['firstd']=None
			log_by_tag[tag_to_write]['lastd']=None
		commits = subprocess.check_output(['git','log',
					'--pretty','--date=short',between])
		commits = commits.decode(sys.getdefaultencoding())
		for commit in commit_data.findall(commits):
			d = datetime.strptime(commit[2],'%Y-%m-%d').date()
			if log_by_tag[tag_to_write]['lastd'] is None:
				 log_by_tag[tag_to_write]['lastd'] = d
			if log_by_tag[tag_to_write]['firstd'] is None \
			or log_by_tag[tag_to_write]['firstd'] > d:
				 log_by_tag[tag_to_write]['firstd'] = d
			if not single_user:
				 log_by_tag[tag_to_write]['authors'].add(commit[1])
			changelog_entry = '\n'.join([l.strip() for l in commit[3].splitlines()])
			log_by_tag[tag_to_write]['changes'].append(changelog_entry)
		if verbose:
			sys.stderr.write('Got the following:\n')
			sys.stderr.write('{}\n'.format(log_by_tag[tag_to_write]))
	f=open('CHANGELOG.md','w')
	for key,item in log_by_tag.items():
		if verbose:
			sys.stderr.write('Writing changelog entry for {}\n'.format(key))
		f.write('{} ({} - {})\n====\n'.format(key,
			item['firstd'].strftime('%m/%d/%Y'),
			item['lastd'].strftime('%m/%d/%Y')))
		if not single_user:
			if verbose:
				sys.stderr.write('Writing authors\n')
			f.write("Authors\n")
			for a in item['authors']:
				f.write('* {}\n'.format(a))
			f.write("\nChanges\n")
		if verbose:
			sys.stderr.write('Writing changes\n')
		for c in item['changes']:
			f.write('* {}\n'.format(c))
		f.write('\n')
	f.close()

def write_changelog(single_user=False, verbose=False):
	commits = subprocess.check_output(['git','log',
					'--pretty','--date=short'])
	commits = commits.decode(sys.getdefaultencoding())

	log_by_date=od([])

	for commit in commit_data.findall(commits):
		date = datetime.strptime(commit[2],'%Y-%m-%d').date()
		if date not in log_by_date.keys():
			if verbose:
				sys.stderr.write('Establishing data cache for {}\n'.format(date))
			log_by_date[date]={}
			if not single_user:
				log_by_date[date]['authors'] = set([])
			log_by_date[date]['changes']=[]
		if not single_user:
			log_by_date[date]['authors'].add(commit[1])
		changelog_entry = '\n'.join([l.strip() for l in commit[3].splitlines()])
		log_by_date[date]['changes'].append(changelog_entry)

	f=open('CHANGELOG.md','w')
	for key,item in log_by_date.items():
		if verbose:
			sys.stderr.write('Writing changelog entry for {}\n'.format(key))
		f.write('{}\n====\n'.format(key.strftime('%m/%d/%Y')))
		if not single_user:
			if verbose:
				sys.stderr.write('Writing authors\n')
			f.write("Authors\n")
			for a in item['authors']:
				f.write('* {}\n'.format(a))
			f.write("\nChanges\n")
		if verbose:
			sys.stderr.write('Writing changes\n')
		for c in item['changes']:
			f.write('* {}\n'.format(c))
		f.write('\n')
	f.close()

if __name__ == "__main__":
	aparser = argparse.ArgumentParser(prog='gitrev2changelog',
					description="Generate a prettified changelog from one's git commits")
	aparser.add_argument('-t','--tagged',
			help="Output a tag oriented changelog",
			action='store_true',default=False)
	aparser.add_argument('-s','--single-user', 
			help='Turn off printing dividers for authors and changes',
			action='store_true',default=False)
	aparser.add_argument('-v','--verbose',
			help='Be noisy when generating the changelog',
			action='store_true',default=False)
	args = aparser.parse_args(sys.argv[1:])
	if args.tagged:
		write_tagged_changelog(args.single_user,args.verbose)
	else:
		write_changelog(args.single_user,args.verbose)
