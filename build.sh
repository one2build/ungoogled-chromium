export ONE2BUILD_DIR=`pwd`

docker build --network host -t markwylde/one2build-ungoogled-chromium .

# # cleanup old build
rm -rf output

# # create the output folder
mkdir -p output
cd output

# # copy ubuntu build from docker image to local machine
docker run -v `pwd`:/output --net host markwylde/one2build-ungoogled-chromium sh -c \
  "cp /build/build/*.* /output && cd /build/build && chown 1000:1000 ."

# # extract the installation files
mkdir chrome-linux

cd chrome-linux
ar x ../ungoogled-chromium_*.deb
tar xf data.tar.xz
rm data.tar.xz
ar x ../ungoogled-chromium-common*.deb
tar xf data.tar.xz
rm data.tar.xz
rm control.tar.xz
rm debian-binary
cd ../

# # create an AppImage from the extracted files
wget -c https://github.com/$(wget -q https://github.com/AppImage/pkg2appimage/releases -O - | grep "pkg2appimage-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
chmod +x ./pkg2appimage-*.AppImage

# cleanup and organise output
./pkg2appimage-*.AppImage ../Chrome.yml
rm -rf Chromium
rm -rf chrome-linux
./out/Chromium-*.AppImage --appimage-extract
mv out/Chromium*.AppImage .
rm -rf out
mv ./squashfs-root ./chromium

# create executable entrypoint
cat > ./chromium/chrome <<EOF
#!/bin/sh
export HERE=\$(dirname \$(readlink -f "\${0}"))
export LD_LIBRARY_PATH="\${HERE}"/usr/lib/x86_64-linux-gnu:\$PATH
"\$HERE"/usr/bin/chromium --password-store=basic \$@
EOF
chmod +x ./chromium/chrome

# fix chromium launcher
sed -i -e 's/\/etc/\$HERE\/etc/g' ./chromium/usr/bin/chromium
sed -i -e 's/\/usr/\$HERE\/usr/g' ./chromium/usr/bin/chromium
