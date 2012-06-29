#!/usr/bin/env python
import subprocess
import re
import sys
import datetime
from dateutil import parser
from collections import OrderedDict as od
import argparse

commit_data=re.compile((r'commit[ ]*([0-9a-f]*)\n'
r'Author:[ ]*([^\n]*)\n'
r'Date:[ ]*([^\n]*)\n{2}'
r'([ ]+[^\n]*\n)*\n'))
on_branch = re.compile(r'^# On branch (.*)$')

def write_changelog(single_user=False):
	curbranch = subprocess.check_output(['git','status'])
	curbranch = curbranch.decode(sys.getdefaultencoding()).splitlines()[0]
	curbranch = on_branch.findall(curbranch)[0]

	commits = subprocess.check_output(['git','rev-list',
					'--branches',curbranch,
					'--pretty'])
	commits = commits.decode(sys.getdefaultencoding())

	log_by_date=od([])

	for commit in commit_data.findall(commits):
		date = parser.parse(commit[2]).date()
		if date not in log_by_date.keys():
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
		f.write('{}\n====\n'.format(key.strftime('%m/%d/%Y')))
		if not single_user:
			f.write("Authors\n")
			for a in item['authors']:
				f.write('* {}\n'.format(a))
			f.write("\nChanges\n")
		for c in item['changes']:
			f.write('* {}\n'.format(c))
		f.write('\n')
	f.close()

if __name__ == "__main__":
	aparser = argparse.ArgumentParser(prog='gitrev2changelog',
					description="Generate a prettified changelog from one's git commits")
	aparser.add_argument('-s','--single-user', 
			help='Turn off printing dividers for authors and changes',
			action='store_true',default=False)
	args = aparser.parse_args(sys.argv[1:])
	write_changelog(args.single_user)
