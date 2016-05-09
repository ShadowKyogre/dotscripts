#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import urwid
from PIL import Image
import os

screen=urwid.raw_display.Screen()
screen.set_terminal_properties(colors=256)

class SelectableText(urwid.Text):
	def __init__(self, *args, **kwargs):
		self.__super.__init__(*args, **kwargs)
		self.orig_text=args[0]
	def selectable(self):
		return True
	def keypress(self, size, key):
		return key
	

def RGBToHTMLColor(rgb_tuple):
	""" convert an (R, G, B) tuple to #RRGGBB """
	r,g,b=rgb_tuple
	r=int(r/255.0*16)
	g=int(g/255.0*16)
	b=int(b/255.0*16)
	if r == 16:
		r = 15
	if g == 16:
		g = 15
	if b == 16:
		b = 15
	hexcolor = '#%x%x%x' % (r,g,b)
	# that's it! '%02x' means zero-padded, 2-digit hex values
	return hexcolor

def scaleToWidth(img, width):
	neww=width
	newh=int(float(width)/img.size[0]*img.size[1])
	return img.resize((neww,newh))
def scaleToHeight(img, height):
	newh=height
	neww=int(float(height)/img.size[1]*img.size[0])
	return img.resize((neww,newh))

#img=img.resize((img.size[0]/4,img.size[1]/4))
#if img.size[0] > screen.get_cols_rows()[0]:
#	img=scaleToWidth(img,screen.get_cols_rows()[0])
#if img.size[1] > screen.get_cols_rows()[1]:
#	img=scaleToHeight(img,screen.get_cols_rows()[1])

img=Image.open(os.path.expanduser(os.sys.argv[1]))
origimg=img.convert('RGB').convert('P', palette=Image.ADAPTIVE, colors=88).convert("RGB")
rimg=origimg
factor=0.20

text=urwid.SimpleListWalker([])
scheme={(' ','','','','','')}

#opacity=('■ ','$',  '@',  'B',  '%',  '8',  '&',  'W',  'M',  '#',  '*',  'o',  'a',  'h',  'k',  'b', 
opacity=('█','$',  '@',  'B',  '%',  '8',  '&',  'W',  'M',  '#',  '*',  'o',  'a',  'h',  'k',  'b',  
#opacity=('$','$',  '@',  'B',  '%',  '8',  '&',  'W',  'M',  '#',  '*',  'o',  'a',  'h',  'k',  'b',  
'd',  'p',  'q',  'w',  'm',  'Z',  'O',  '0',  'Q',  'L',  'C',  'J',  'U',  'Y',  'X',  
'z',  'c',  'v',  'u',  'n',  'x',  'r',  'j',  'f',  't',  '/',  '\\',  '|',  '(',  ')',  
'1',  '{',  '}',  '[',  ']',  '?',  '-',  '_',  '+',  '~',  '<',  '>',  'i',  '!',  'l',  
'I',  ';',  ':',  ',',  '"',  '^',  '`',  "'",  '.',  ' ')

def process_pixel(pixel):
	if len(pixel) == 4:
		opchar=71-int(pixel[-1]/255.0*71)
		if opchar == 71:
			opchar=70
		#print opchar
		if pixel[-1] == 0:
			scol=' '
		else:
			scol = RGBToHTMLColor(pixel[:-1])
		#print(pixels[x,y][:-1],scol)
	else:
		opchar=0
		scol = RGBToHTMLColor(pixel)
		#print(pixels[x,y][:-1],scol)
	return scol,opacity[opchar]	

def refresh_palette():
	global termpal
	global scheme
	global screen
	global rimg
	termpal=[]
	for x,col in enumerate(rimg.getcolors()):
	        termpal.append((col[1][0],col[1][1],col[1][2]))
        	#c,_=process_pixel(col[1])
	        scheme.add(('s{}'.format(x),'','','','h{}'.format(x),''))

	#print(termpal)
	#print(scheme)
	screen.modify_terminal_palette([(x,t[0],t[1],t[2]) for x,t in enumerate(termpal)])

#this needs to only render what is visible like bro suggested
def refresh_img():
	global factor
	global rimg
	global origimg
	mtext=[]
	rimg=origimg.resize((int(origimg.size[0]*factor),int(origimg.size[1]*factor)))
	w,h=rimg.size
	pixels=rimg.load()
	del text[:]
	for y in xrange(h):
		for x in xrange(w):
			#pixel_text=process_pixel(pixels[x,y])
			i=termpal.index(pixels[x,y])
			mtext.append(('s{}'.format(i),opacity[0]))
			#if not [s for s in scheme if s[0] == pixel_text[0]]:
			#scheme.add((pixel_text[0],'','','',pixel_text[0],''))
		text.append(SelectableText(mtext, wrap='clip', align='center'))
		mtext=[]
	#text.append((' ','\n'))
#print(text)

pos=0
panel=40

refresh_palette()
refresh_img()

def keypress(key):
	screen.modify_terminal_palette([(x,t[0],t[1],t[2]) for x,t in enumerate(termpal)])
	#status.set_text("{}:{}".format(loop.screen.get_cols_rows(),cols))
	pref_size=screen.get_cols_rows()[0]
	global pos
	global factor
	global origimg
	global rimg
	#status.set_text("{},{}".format(pos,pos+pref_size))
	if key == '+':
		factor+=0.1
		if factor > 2.0:
			factor=2.0
		status.set_text("{img.size[0]}x{img.size[1]} ({factor})".format(img=origimg,factor=factor))
		refresh_img()
		screen.clear()
		return True
	if key == '-':
		factor-=0.1
		if factor <= 0 or abs(0-factor) < 0.00001:
			factor=0.1
		status.set_text("{img.size[0]}x{img.size[1]} ({factor})".format(img=origimg,factor=factor))
		refresh_img()
		screen.clear()
		return True
	if key in ('q', 'Q'):
		screen.reset_default_terminal_palette()
		raise urwid.ExitMainLoop()
	if key == 'right':
		pos+=pref_size/2
		if pos > rimg.size[0]-pref_size/2:
			pos=rimg.size[0]-pref_size/2
		for text in txt.body:
			text.set_text(text.orig_text[pos:pos+pref_size])
		return True
	if key == 'left':
		pos-=pref_size/2
		if pos < 0:
			pos=0
		for text in txt.body:
			text.set_text(text.orig_text[pos:pos+pref_size])
		return True
	return False

txt = urwid.ListBox(text)
fill = urwid.Filler(urwid.BoxAdapter(txt,panel), 'middle')
status=urwid.Text("{img.size[0]}x{img.size[1]}".format(img=origimg),align='left')
fname=urwid.Text(os.path.expanduser(os.sys.argv[1]),align='right')
#import pdb; pdb.set_trace()
loop = urwid.MainLoop(urwid.Frame(fill,footer=urwid.Columns([status,fname])),screen=screen,
		palette=scheme,unhandled_input=keypress)
#	unhandled_input=keypress)
loop.run()
