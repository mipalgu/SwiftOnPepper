# Lazy Man's Approach

1. Download and untar the prebuilt pepper toolchain from /var/archive:
```bash
# For Mac
scp ssh://cat.mipal.net/var/archive/naoqi-sdk-2.5.5.5-pepper-mac64.tar.gz ~/Downloads/
cd /usr/local && tar -xzvf ~/Downloads/naoqi-sdk-2.5.5.5-pepper-mac64.tar.gz

# For Linux
scp ssh://cat.mipal.net/var/archive/naoqi-sdk-2.5.5.5-pepper-mac64.tar.gz ~/Downloads/
cd /usr/local && tar -xzvf ~/Downloads/naoqi-sdk-2.5.5.5-pepper-mac64.tar.gz
```

2. Try out your new toolchain:
```bash
cd ~/src/MiPal/GUNao/posix/tutorials/hello-swift
bmake robot TARGET=pepper
```

# Prerequisites
This repository is responsible for compiling the swift language for the
pepper robot. Several scripts have been created which automatically
build swift in a docker container. The docker container clones
a repository (located at ssh://git.mipal.net/git/nao_swift.git) and
runs these scripts in a 64 bit ubuntu environment. The build also requires
an existing cross toolchain in order to use the appropriate cross
compilers and system libraries/headers for the pepper needed by the swift build.
Therefore, in order to actually execute the built there are several
prerequesites that must be met:

1. A valid installation of docker on the system.

2. The cross toolchain for the pepper (ctc-linux64-atom-2.5.2.74.zip) that can
be downloaded from the aldebaran community website
(https://community.aldebaran.com/en/resources/software) or alternatively
can be accessed from /var/archive on cat.

3. Your private ssh key (probably located at ~/.ssh/id_rsa) that you
use to clone repositories off of git.mipal.net so that you
may download the repository containing the build scripts from within the
dockerfile. This is neccessary as long as the repository remains private.

4. The naoqi C++ sdk (naoqi-sdk-2.5.5.5-linux64 for linux,
naoqi-sdk-2.5.5.5-mac64 for mac) downloaded from
the aldebaran community website
(https://community.aldebaran.com/en/resources/software).

5. Place the cross toolchain and your ssh key into the folder where this
README.md resides.

# Quick Start

1. Make sure you have met all prerequisites.
2. Build Swift:
```bash
./build.sh
```
3. Copy all the build products:
```bash
./copy.sh ~/Downloads
```
4. Create a pepper folder in /usr/local:
```bash
mkdir -p /usr/local/pepper
```
5. Untar the naoqi sdk:
```bash
# Linux
cd /usr/local/pepper
tar -xzvf ~/Downloads/naoqi-sdk-2.5.5.5-linux64.tar.gz

# Mac
cd /usr/local/pepper
tar -xzvf ~/Downloads/naoqi-sdk-2.5.5.5-mac64.tar.gz
```
6. Untar `ctc-mipal.tar.gz`:
```bash
# Linux
cd /usr/local/pepper/naoqi-sdk-2.5.5.5-linux64
tar -xzvf ~/Downloads/ctc-mipal.tar.gz

# Mac
cd /usr/local/pepper/naoqi-sdk-2.5.5.5-mac64
tar -xzvf ~/Downloads/ctc-mipal.tar.gz
```
7. Untar `crosstoolchain.tar.gz`:
```bash
# Linux
cd /usr/local/pepper/naoqi-sdk-2.5.5.5-linux64
tar -xzvf ~/Downloads/crosstoolchain.tar.gz

# Mac
cd /usr/local/pepper/naoqi-sdk-2.5.5.5-mac64
tar -xzvf ~/Downloads/crosstoolchain.tar.gz
```
8. If on mac, compile and install a cross binutils:
```bash
mkdir -p ~/src/binutils
cd ~/src/binutils
wget https://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz
tar -xzvf binutils-2.25.tar.gz
mkdir build-binutils
cd build-binutils
../binutils-2.25/configure --target=i686-aldebaran-linux-gnu --prefix=/usr/local/pepper/naoqi-sdk-2.5.5.5-mac64/crosstoolchain/cross/atom
make
make install
```
9. Patch glibc.modulemap:
```bash
# Linux
cd /usr/local/pepper/naoqi-sdk-2.5.5.5-linux64/crosstoolchain/staging/i686-aldebaran-linux-gnu/home/nao/swift-tc/lib/swift/linux/i686
cp glibc.modulemap glibc.modulemap.orig
sed -e "s@header \".*/usr/@header \"/usr/local/pepper/naoqi-sdk-2.5.5.5-linux64/crosstoolchain/staging/i686-aldebaran-linux-gnu/usr/@g" glibc.modulemap.orig > glibc.modulemap

# Mac
cd /usr/local/pepper/naoqi-sdk-2.5.5.5-mac64/crosstoolchain/staging/i686-aldebaran-linux-gnu/home/nao/swift-tc/lib/swift/linux/i686
cp glibc.modulemap glibc.modulemap.orig
sed -e "s@header \".*/usr/@header \"/usr/local/pepper/naoqi-sdk-2.5.5.5-mac64/crosstoolchain/staging/i686-aldebaran-linux-gnu/usr/@g" glibc.modulemap.orig > glibc.modulemap
```
10. Try out your new toolchain:
```bash
cd ~/src/MiPal/GUNao/posix/tutorials/hello-swift
bmake robot TARGET=pepper
```

# Detailed Instructions

## Cross compiling swift for the pepper.

Once you have successfully met all prerequisites you may simply execute
the build script:
```bash
./build.sh
```
This will setup the docker container and install ubuntu 18.04. Once this
has happened the build will then proceed with downloaded the neccessary source
files for the swift project and compiling them for the supported version of
swift. At the moment, this is version 5.2. Note: if you are compiling
swift from outside of the university network, you do need to vpn in during
the execution of the build script.

## Running the Docker container and copying the neccessary files.

Once the build script has finished executing, swift has successfully been
built. It is then necessary to run the docker container and copy the necessary
files. To create a running instance
