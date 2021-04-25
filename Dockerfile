FROM ubuntu:20.04

RUN mkdir -p /build/out

WORKDIR /build

# BUILD

# Step 1) Prepare OS with dependencies needed
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update --fix-missing && apt-get -y upgrade && apt-get install -y \
  git python3 packaging-dev equivs

# Step 2) Clone ungoogled chromium debian
RUN git clone --recurse-submodules https://github.com/ungoogled-software/ungoogled-chromium-debian.git
RUN git -C ungoogled-chromium-debian checkout ubuntu_focal
RUN git -C ungoogled-chromium-debian submodule update --init --recursive

# Step 3) Build the project
RUN mkdir -p build/src
RUN cp -r ungoogled-chromium-debian/debian build/src/
WORKDIR build/src

RUN ./debian/scripts/setup debian

RUN yes | mk-build-deps -i debian/control
RUN rm ungoogled-chromium-build-deps_*

RUN ./debian/scripts/setup local-src

COPY flags.gn /tmp/flags.gn
RUN cat /tmp/flags.gn >> /build/build/src/debian/ungoogled-upstream/ungoogled-chromium/flags.gn

RUN dpkg-buildpackage -b -uc

# Step 4) Clean up any old outputs
RUN rm -rf /build/out/*

# Step 5) Copy ubuntu build from docker image to local machine
WORKDIR /build/out
RUN cp /build/build/*.* /build/out && cd /build/build
RUN chown 1000:1000 .

# PORTABLE

# Step 6) Extract the installation files
RUN mkdir /build/out/chrome-linux

WORKDIR /build/out/chrome-linux
RUN ar x ../ungoogled-chromium_*.deb
RUN tar xf data.tar.xz
RUN rm data.tar.xz
RUN ar x ../ungoogled-chromium-common*.deb
RUN tar xf data.tar.xz
RUN rm data.tar.xz
RUN rm control.tar.xz
RUN rm debian-binary

WORKDIR /build/out

# Step 7) Make chromium launcher use correct paths
RUN sed -i -e 's/\/etc/\$HERE\/etc/g' ./chrome-linux/usr/bin/chromium
RUN sed -i -e 's/\/usr/\$HERE\/usr/g' ./chrome-linux/usr/bin/chromium

# Step 8) Create an AppImage from the extracted files
RUN wget -c https://github.com/$(wget -q https://github.com/AppImage/pkg2appimage/releases -O - | grep "pkg2appimage-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
RUN chmod +x ./pkg2appimage-*.AppImage
