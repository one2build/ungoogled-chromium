# Ungoogled Chromium (one2build)
This repo will allow you to build Ungoogled Chromium from source, using docker, with just one command.

## Usage
```bash
git clone https://github.com/one2build/ungoogled-chromium
cd ungoogled-chromium
./build.sh
```

The builds will be put into an `output` directory where you cloned.

The final finals contain:

### Chromium-.glibc*.AppImage
This is a portable single executable that should run Ungoogled Chromium on any linux operating system.

### chromium
This is a folder that contains everything needed to run Ungoogled Chromium. It should be portable too.

### ungoogled-chromium*.dev
A bunch of debian packages to install Ungoogled Chromium
