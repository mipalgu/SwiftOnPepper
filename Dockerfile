# Kudos to DOROWU for his amazing VNC 18.04 LXDE image
FROM dorowu/ubuntu-desktop-lxde-vnc:bionic AS mipal-pepper-swift-crosstoolchain-build
LABEL maintainer "info@mipal.net.au"

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl wget dirmngr

#
# Install development environment
#
ARG LLVMVER=8
ENV LLVMVER=$LLVMVER
RUN apt-get -y install git git-svn build-essential libc++-dev clang bmake pmake cmake ninja-build llvm-${LLVMVER}-dev libclang-${LLVMVER}-dev libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev libavahi-core-dev libavahi-client-dev libavahi-common-dev libavahi-compat-libdnssd1 python-dev ruby-dev libicu-dev ghc libffi-dev libcairo2-dev libart-2.0-dev portaudio19-dev libxslt1-dev libreadline-dev libjpeg-turbo8-dev libtiff5-dev libpng-dev libgif-dev libgnutls28-dev libsndfile1-dev libasound2-dev alsa-oss libao-dev libaspell-dev libxt-dev libxext-dev libxft-dev mdns-scan autoconf libtool libedit-dev libssl-dev swig libgmp-dev libmpfr6 libmpfr-dev libmpc-dev subversion libcups2-dev flite1-dev liblldb-${LLVMVER}-dev libmpc-dev libxt-dev graphviz doxygen dia gcc-avr gdb-avr avr-libc binutils-avr simulavr avrdude arduino libusbprog-dev sdcc sdcc-doc sdcc-libraries libcsfml-dev libglfw3-dev libgtk-3-dev gir1.2-gtksource-3.0 gobject-introspection libgirepository1.0-dev curl bison cabal-install libopencv-core-dev libopencv-imgproc-dev libopencv-calib3d-dev libopencv-ts-dev libopencv-features2d-dev libopencv-flann-dev libopencv-highgui-dev libopencv-ml-dev libopencv-objdetect-dev libopencv-photo-dev libopencv-video-dev libopencv-dev texinfo apt-transport-https ca-certificates curl gnupg-agent software-properties-common libsqlite3-dev

#
# Install SwiftEnv
#

RUN mkdir -p /usr/local/var \
    && git clone https://github.com/kylef/swiftenv.git /usr/local/var/swiftenv \
    && [ ! -e /usr/local/var/swiftenv/versions ] || chown `basename $HOME` /usr/local/var/swiftenv/versions \
    && bash -c 'echo export SWIFTENV_ROOT="/usr/local/var/swiftenv" >/etc/profile.d/swiftenv.sh' \
    && echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' | $SUDO tee -a /etc/profile.d/swiftenv.sh \
    && echo 'eval "$(swiftenv init -)"' | $SUDO tee -a /etc/profile.d/swiftenv.sh \
    && echo >>/tmp/final.msg '' \
    && echo >>/tmp/final.msg ' *** To use Swift, either restart, log out/in or run:' \
    && echo >>/tmp/final.msg '' \
    && echo >>/tmp/final.msg 'source /etc/profile.d/swiftenv.sh'
