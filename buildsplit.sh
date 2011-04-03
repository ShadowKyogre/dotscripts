#!/bin/bash

export PKGBUILD="$(pwd)/PKGBUILD"

echo "Turning split PKGBUILD into individual PKGBUILDS.
This will NOT perform a quality check on the PKGBUILD beforehand.
You will have make sure the PKGBUILD abides by guidelines
before submitting it!

You may also need to edit the new PKGBUILDs for some minor annoyances
and some certain things, like makedepends.
"

source $PKGBUILD

	build_functions="${pkgname[@]}"
	echo "Turning $pkgbase into these package PKGBUILDS: $build_functions"
	
for lump in $build_functions; do
	echo "Working on $lump"

	if [ ! -e "$(pwd)/${lump}" ];then
		echo "Making directory for $lump"
		mkdir ./${lump}
	fi

	echo "Setting package name"
	echo "pkgname=$lump" > ./${lump}/PKGBUILD
	echo "Copying variables..."
	for name in $(grep -v '^pkgname=' $PKGBUILD|grep "^[[:alnum:]]*=") ; do
		echo $name >> ./${lump}/PKGBUILD
	done
	echo "Copying build function..."
	type build|tail -n +2 >> ./${lump}/PKGBUILD
	echo "Copying package function for $lump"
	type "package_"$lump|tail -n +2|sed "s|^package_$lump *()|package ()|" >> ./${lump}/PKGBUILD

	echo "Copying additional source file for $lump"
	for sourcefile in $(grep '^source=(.*)$' $PKGBUILD|sed 's/^source=//g;s/["'\''\(\)]//g') ; do
		if [ -e ./$sourcefile ];then
		echo "Yes, the file really does exist"
		cp -vf ./$sourcefile ./${lump}
		fi
	done

	echo "Copying install file for $lump"
	if [ -e ./$(grep 'install=' ./"${lump}"/PKGBUILD|cut -d= -f2|sed 's|;||g') ];then
		echo "Yes, the file really does exist"
		cp -vf ./$(grep 'install=' ./"${lump}"/PKGBUILD|cut -d= -f2|sed 's|;||g') ./${lump}
	fi
	echo "Done making PKGBUILD and PKGBUILD needed files for $lump"
done
