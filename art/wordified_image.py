#!/usr/bin/env python3

from argparse import ArgumentParser

from scipy.misc import imread
import matplotlib.pyplot as plt

from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator

aparser = ArgumentParser()
aparser.add_argument('words_file')
aparser.add_argument('source_image_file')
aparser.add_argument('output_image_file', nargs="?", default=None)
aparser.add_argument('--mask-image-file', "-mif", default=None)
aparser.add_argument('--background-color', "-bc", default=None)
aparser.add_argument('--font', default=None)
aparser.add_argument('--max-font-size', '-mfs', default=None, type=int)
args = aparser.parse_args()

# Read the whole text.
with open(args.words_file, 'r', encoding='utf-8') as wfile:
	text = wfile.read()

	# read the mask / color image
	# taken from http://jirkavinse.deviantart.com/art/quot-Real-Life-quot-Alice-282261010
	cloud_coloring = imread(args.source_image_file)
	if args.mask_image_file is not None:
		cloud_mask = imread(args.mask_image_file)
	else:
		cloud_mask = cloud_coloring

	wc = WordCloud(background_color=args.background_color, max_words=2000, 
	               mask=cloud_mask, font_path=args.font,  
	               stopwords=STOPWORDS.add("said"), mode="RGBA",
	               max_font_size=args.max_font_size, random_state=42)
	# generate word cloud
	wc.generate(text)

	# create coloring from image
	image_colors = ImageColorGenerator(cloud_coloring)

	if args.output_image_file is not None:
		wc.recolor(color_func=image_colors).to_file(args.output_image_file)
	else:
		# show
		#plt.imshow(wc)
		#plt.axis("off")
		#plt.figure()
		# recolor wordcloud and show
		# we could also give color_func=image_colors directly in the constructor
		plt.imshow(wc.recolor(color_func=image_colors))
		plt.axis("off")
		#plt.figure()
		#plt.imshow(cloud_coloring, cmap=plt.cm.gray)
		#plt.axis("off")
		plt.show()
