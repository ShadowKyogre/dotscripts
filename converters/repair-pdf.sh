#!/bin/sh

gs -o "$2" \
	-sDEVICE=pdfwrite \
	-dPDFSETTINGS=/prepress \
	"$1"
