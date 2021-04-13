FROM ubuntu:20.04

WORKDIR /build

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update --fix-missing && apt-get -y upgrade && apt-get install -y \
  git python3 packaging-dev equivs

RUN git clone --recurse-submodules https://github.com/ungoogled-software/ungoogled-chromium-debian.git

RUN git -C ungoogled-chromium-debian checkout --recurse-submodules ubuntu_focal

RUN mkdir -p build/src
RUN cp -r ungoogled-chromium-debian/debian build/src/
WORKDIR build/src

RUN ./debian/scripts/setup debian

RUN yes | mk-build-deps -i debian/control
RUN rm ungoogled-chromium-build-deps_*

COPY flags.gn /tmp/flags.fn
RUN cat /tmp/flags.gn >> /build/build/src/out/Release/args.gn

RUN ./debian/scripts/setup local-src

RUN dpkg-buildpackage -b -uc
