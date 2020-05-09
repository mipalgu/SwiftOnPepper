# Kudos to DOROWU for his amazing VNC 18.04 LXDE image
FROM dorowu/ubuntu-desktop-lxde-vnc:bionic AS mipal-pepper-swift-crosstoolchain-build
LABEL maintainer "info@mipal.net.au"

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl wget dirmngr

#
# Install development environment
#
ARG LLVMVER=8
ENV LLVMVER=$LLVMVER
RUN apt-get -y install git git-svn build-essential libc++-dev clang bmake pmake cmake ninja-build llvm-${LLVMVER}-dev libclang-${LLVMVER}-dev libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev libavahi-core-dev libavahi-client-dev libavahi-common-dev libavahi-compat-libdnssd1 python-dev ruby-dev libicu-dev ghc libffi-dev libcairo2-dev libart-2.0-dev portaudio19-dev libxslt1-dev libreadline-dev libjpeg-turbo8-dev libtiff5-dev libpng-dev libgif-dev libgnutls28-dev libsndfile1-dev libasound2-dev alsa-oss libao-dev libaspell-dev libxt-dev libxext-dev libxft-dev mdns-scan autoconf libtool libedit-dev libssl-dev swig libgmp-dev libmpfr6 libmpfr-dev libmpc-dev subversion libcups2-dev flite1-dev liblldb-${LLVMVER}-dev libmpc-dev libxt-dev graphviz doxygen dia gcc-avr gdb-avr avr-libc binutils-avr simulavr avrdude arduino libusbprog-dev sdcc sdcc-doc sdcc-libraries libcsfml-dev libglfw3-dev libgtk-3-dev gir1.2-gtksource-3.0 gobject-introspection libgirepository1.0-dev curl bison cabal-install libopencv-core-dev libopencv-imgproc-dev libopencv-calib3d-dev libopencv-ts-dev libopencv-features2d-dev libopencv-flann-dev libopencv-highgui-dev libopencv-ml-dev libopencv-objdetect-dev libopencv-photo-dev libopencv-video-dev libopencv-dev texinfo apt-transport-https ca-certificates curl gnupg-agent software-properties-common libsqlite3-dev zlib1g-dev screen nano vim less

#
# Install a newer version of cmake
#
RUN mkdir -p /root/src/cmake
RUN cd /root/src/cmake && wget https://github.com/Kitware/CMake/releases/download/v3.15.2/cmake-3.15.2.tar.gz
RUN cd /root/src/cmake && tar -xzvf cmake-3.15.2.tar.gz
RUN mkdir -p /root/src/cmake/build
RUN cd /root/src/cmake/build && CC=/usr/bin/clang CXX=/usr/bin/clang++ ../cmake-3.15.2/configure --prefix=/usr/local && make && make install
RUN rm -rf /root/src

#
# Install SwiftEnv
#
ARG SWIFTENV_ROOT_ARG=/usr/local/var/swiftenv
ENV SWIFTENV_ROOT_ARG=$SWIFTENV_ROOT_ARG

Run mkdir -p /home/ubuntu/.swiftenv
RUN mkdir -p /usr/local/var \
    && git clone https://github.com/kylef/swiftenv.git /usr/local/var/swiftenv \
    && bash -c 'echo export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" >> .bashrc' \
    && echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' | tee -a .bashrc \
    && echo 'eval "$(swiftenv init -)"' | tee -a .bashrc
RUN cp /root/.bashrc /home/ubuntu/
RUN cp /root/.profile /home/ubuntu/

#
# Setup source tree
#
RUN mkdir -p /root/src
COPY nao_swift /root/src/
#RUN cd /root/src && git clone ssh://git.mipal.net/git/nao_swift.git
COPY ctc-linux64-atom-2.5.2.74.zip /root/src/nao_swift/pepper/
RUN cd /root/src/nao_swift/pepper && unzip ctc-linux64-atom-2.5.2.74.zip

ARG DEBUG=0
ENV DEBUG=$DEBUG

#
# Configure git repo.
#
ARG GIT_USERS_NAME=root
ENV GIT_USERS_NAME=$GIT_USERS_NAME
ARG GIT_USERS_EMAIL=root@pepper-swift
ENV GIT_USERS_EMAIL=$GIT_USERS_EMAIL
RUN if [ "$DEBUG" = "1" ] ; then cd /root/src/nao_swift && \
    git config user.name "$GIT_USERS_NAME" && \
    git config user.email "$GIT_USERS_EMAIL"; fi

#
# Setup ssh keys.
#
ARG SSH_USER
ENV SSH_USER=$SSH_USER
RUN mkdir -p /root/.ssh
COPY .build/* /root/.ssh/
RUN if [ "$DEBUG" = "1" ] ; then chmod 600 /root/.ssh/*; fi
RUN if [ "$DEBUG" = "1" ] ; then rm -f /root/.ssh/config; fi
RUN if [ "$DEBUG" = "1" ] ; then echo "host git.mipal.net" >> /root/.ssh/config && \
  echo "  HostName git.mipal.net" >> /root/.ssh/config && \
  echo "  IdentityFile /root/.ssh/id_rsa" >> /root/.ssh/config && \
  echo "  User ${SSH_USER}" >> /root/.ssh/config; fi
RUN rm -f /root/.ssh/known_hosts
RUN touch /root/.ssh/known_hosts
RUN if [ "$DEBUG" = "1" ] ; then ssh-keyscan git.mipal.net >> /root/.ssh/known_hosts; fi

#
# Install Swift
#
ARG SWIFTVER=5.1
ENV SWIFTVER=$SWIFTVER

RUN bash -c '\
    SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" $SWIFTENV_ROOT_ARG/bin/swiftenv install $SWIFTVER \
    && SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" $SWIFTENV_ROOT_ARG/bin/swiftenv global $SWIFTVER'

ARG PARALLEL=1

#
# Build swift.
#
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./setup.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./setup-sources.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./setup-sysroot.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-cross-binutils.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-libuuid.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-icu.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-host-llvm.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-target-llvm.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-swift.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-libdispatch.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-foundation.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./build-xctest.sh -j$PARALLEL -l -s "$SWIFTVER"
RUN cd /root/src/nao_swift/pepper && \
    export SWIFTENV_ROOT="$SWIFTENV_ROOT_ARG" && \
    export PATH="$SWIFTENV_ROOT/bin:$PATH" && \
    eval "$(swiftenv init -)" && \
    ./finalise.sh -j$PARALLEL -l -s "$SWIFTVER"
