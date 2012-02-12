#!/bin/bash

source $1

parse_metadata()
{
echo "Name: $pkgname"
echo "Version: $pkgver"
echo "Release: $pkgrel%{?dist}"
echo "Summary: $pkgdesc"
echo "License: ${license[@]}"
echo "URL: $url"
for (( i = 0 ; i < ${#source[@]} ; i++ ));do
	echo "Source${i}: ${source[$i]}"
done
echo "BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)"

echo -e "BuildRequires: ${makedepends[@]}"
echo -e "Requires: ${depends[@]}"

echo "%description $pkgdesc"
echo ""
}

#$1 = func
#$2 = tag
parse_func()
{
if [[ $(type -t "${1}") == "function" ]];then
	#echo -e "%${2}\n$(type "${1}"|head -n-1|tail -n-7)\n" \ |
	echo -e "%${2}\n$(type "${1}"|sed "/${1} is a function/d;/${1} ()/d;s/^[{}].*$//g")\n"
fi
}

correct()
{
	sed -e 's/\${\?srcdir}\?/%_builddir/g' -i "$1"
	sed -e 's/\${\?pkgdir}\?/%_buildrootdir/g' -i "$1"
	sed -e 's/\(pre|post\)*_install/\1trans/g' -i "$1"
	sed -e 's/\(pre|post\)*_upgrade/\1/g' -i "$1"
	sed -e 's/\(pre|post\)*_uninstall/\1un/g' -i "$1"
}

main()
{
parse_metadata

echo -e "%prep\n%setup -qn %_builddir/${pkgname}-${pkgver} -c %_builddir/${pkgname}-${pkgver}\n"
#echo -e "%build\n$(type build|head -n-1|tail -n-7)\n"
parse_func build build
parse_func check check
parse_func package "install"

echo "%files"
echo "%defattr(-,root,root,-)"
echo "/"
echo

if [[ ! -z "$install" ]];then
	source "$(dirname $(realpath "$1"))/$install"
	parse_func pre_install pretrans
	parse_func post_install posttrans
	parse_func pre_upgrade pre
	parse_func post_upgrade post
	parse_func pre_uninstall preun
	parse_func post_uninstall postun
fi

echo "%changelog"
#* Wed Apr 02 2008 Zdenek Prikryl <zprikryl at, redhat.com> 2.1.5-11
echo "* $(date '+%a %b %d %Y') $(getent passwd "$USER" | cut -d ':' -f 5) <youremail at domain.ext> ${pkgver}-${pkgrel}"
echo "- Converted PKGBUILD to spec"
}
output="$pkgname-$pkgver.spec"
main "$1" > "$output"
correct "$output"