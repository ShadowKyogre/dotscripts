#!/usr/bin/env python2

from argparse import ArgumentParser
from os import path, makedirs
import subprocess

from sys import stderr
# at least until I find out how to use hg directly in script

BB_TEMPLATE="ssh://hg@bitbucket.org{ssh_suffix}/{user}/{repo_name}"

parser = ArgumentParser(description="Create many repos from filemaps")
parser.add_argument('-s', '--source',
	default='.',
	help='Target repo to extract from')

parser.add_argument('-d', '--dest',
	default='/tmp/hg-batches',
	help='Where to put generated repos')

parser.add_argument('-g', '--generate-push-urls',
	default=False,
	action='store_true',
	help='Generate push urls for target repos')

parser.add_argument('-x', '--ssh-suffix',
	default='',
	help='ssh specific suffixes for template')

parser.add_argument('-u', '--user',
	default='<FakeUser>',
	help='User for push urls')

parser.add_argument('-e', '--email',
	default=None,
	help='Email for push urls')

parser.add_argument('filemaps', nargs='+')

args = parser.parse_args()

if not path.exists(args.dest):
	os.makedirs(args.dest)

for fmap in args.filemaps:
	repo_name = path.splitext(path.basename(fmap))[0]
	repo_path = os.path.join(args.dest, repo_name)

	subprocess.call([
		'hg', 'convert',
		'--filemap', fmap,
		args.target,
		repo_path,
	])

	hg_path = path.join(repo_path, '.hg')
	hg_exist = path.exists(hg_path)

	if hg_exist:
		subprocess.call([
			'hg',
			'--repository', repo_path,
			'update'
		])

	if args.generate_push_urls:
		if hg_exist:
			with open(path.join(hg_path, 'hgrc'), 'a', encoding='utf-8') as f:
				filled_tpl = args.template.format({
					'repo_name':repo_name,
					'user': args.user,
					'ssh_suffix':args.ssh_suffix,
				})

				if args.email is not None:
					wip_user = "{0} <{1}>".format(args.user, args.email)
				else:
					wip_user = args.user

				f.writelines([
					"[paths]",
					"default = {0}".format(filled_tpl),
					"[ui]",
					"user = {0}".format(wip_user),
				])
