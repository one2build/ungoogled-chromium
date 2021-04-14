rm -rf output
mkdir -p output

docker build -t one2build/ungoogled-chromium .
docker run -v `pwd`/output:/output --net host one2build/ungoogled-chromium sh -c \
  "ls && cp -r /build/out/* /output && chown -R 1000:1000 /output"

export ONE2BUILD_DIR=`pwd`

cd output

# Step 9) Package app
./pkg2appimage-*.AppImage ../Chrome.yml

# Step 10) Cleanup and organise output
rm -rf Chromium
rm -rf chrome-linux
./out/Chromium-*.AppImage --appimage-extract
mv ./out/Chromium*.AppImage .
rm -rf out
rm -rf chromium
mv ./squashfs-root ./chromium

# Step 11) Create executable entrypoint
cp ../chrome.template ./chromium/chrome
chmod +x ./chromium/chrome
cd ../
