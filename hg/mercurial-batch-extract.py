#!/usr/bin/env python3

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

parser.add_argument('-o', '--owner',
	default='<FakeUser>',
	help='User for push urls')

parser.add_argument('-u', '--user',
	default='<FakeUser>',
	help='User for commits')

parser.add_argument('-e', '--email',
	default=None,
	help='Email for commits')

parser.add_argument('-t', '--template',
	default=BB_TEMPLATE,
	help='Template for push urls')

parser.add_argument('filemaps', nargs='+')

args = parser.parse_args()

if not path.exists(args.dest):
	makedirs(args.dest)

if args.email is not None:
	wip_user = "{0} <{1}>".format(args.user, args.email)
else:
	wip_user = args.user

for fmap in args.filemaps:
	repo_name = path.splitext(path.basename(fmap))[0]
	repo_path = path.join(args.dest, repo_name)

	subprocess.call([
		'hg', 'convert',
		'--filemap', fmap,
		args.source,
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
		hgrc = path.join(hg_path, 'hgrc')
		filled_tpl = args.template.format(**{
			'repo_name':repo_name,
			'user': args.owner,
			'ssh_suffix':args.ssh_suffix,
		})

		if hg_exist:
			if not path.exists(hgrc):
				with open(hgrc, 'w', encoding='utf-8') as f:
					f.writelines([
						"[paths]\n",
						"default = {0}\n".format(filled_tpl),
						"[ui]\n",
						"user = {0}\n".format(wip_user),
					])
			else:
				with open(hgrc, 'a', encoding='utf-8') as f:
					f.writelines([
						"[paths]\n",
						"default = {0}\n".format(filled_tpl),
						"[ui]\n",
						"user = {0}\n".format(wip_user),
					])
