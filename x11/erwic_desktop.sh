#!/bin/bash

json_path="${HOME}/.config/Vieb/erwic/${1}.json"
outname="${HOME}/.local/share/applications/vieb/${1}.desktop"
name="$(jq -r .name "${json_path}")"
desc="Run ${name} in a Vieb container"
icon="$(jq -r .icon "${json_path}")"

if [[ "${icon:0:1}" != '/' ]]; then
	icon="$(realpath "$(dirname ${json_path})/${icon}")"
fi

if [ ! -d "$(dirname "${outname}")" ]; then
	mkdir -p "$(dirname "${outname}")"
fi

echo "[Desktop Entry]" > "${outname}"
echo "Name=${name}" >> "${outname}"
echo "Comment=${desc}" >> "${outname}"
echo "Icon=${icon}" >> "${outname}"
echo "Exec=vieb --erwic ${json_path} --datafolder ${data_path}" >> "${outname}"
echo "Terminal=false" >> "${outname}"
echo "Type=Application" >> "${outname}"
echo "Terminal=false" >> "${outname}"
echo "Categories=Network;WebBrowser" >> "${outname}"

