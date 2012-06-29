import subprocess
import re
import sys
import datetime
from dateutil import parser
from collections import OrderedDict as od

commit_data=re.compile((r'commit[ ]*([0-9a-f]*)\n'
r'Author:[ ]*([^\n]*)\n'
r'Date:[ ]*([^\n]*)\n{2}'
r'([ ]+[^\n]*\n)*\n'))

commits = subprocess.check_output(['git','rev-list','--all','--pretty'])
commits = commits.decode(sys.getdefaultencoding())

log_by_date=od([])

for commit in commit_data.findall(commits):
	date = parser.parse(commit[2]).date()
	if date not in log_by_date.keys():
		log_by_date[date]={'authors':set([]),
			'changes':[]}
	log_by_date[date]['authors'].add(commit[1])
	#print(commit)
	changelog_entry = '\n'.join([l.strip() for l in commit[3].splitlines()])
	log_by_date[date]['changes'].append(changelog_entry)

f=open('CHANGELOG.md','w')
for key,item in log_by_date.items():
	print(item)
	f.write('{}\n====\n'.format(key.strftime('%m/%d/%Y')))
	f.write("Authors\n")
	for a in item['authors']:
		f.write('* {}\n'.format(a))
	f.write("\nChanges\n")
	for c in item['changes']:
		f.write('* {}\n'.format(c))
	f.write('\n')
f.close()
