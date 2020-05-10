#! /bin/sh
set -e

source setup.sh
source build.sh
./copy.sh $BUILD_DIR


# Setup prefix
mkdir -p $PREFIX
tar -xzvf $NAOQI_SDK_TAR -C $PREFIX
tar -xzvf $BUILD_DIR/ctc-mipal.tar.gz -C $PREFIX/$NAOQI_SDK
tar -xzvf $BUILD_DIR/crosstoolchain.tar.gz -C $PREFIX/$NAOQI_SDK

# Build a cross binutils
mkdir -p $SRC_DIR/binutils
cd $SRC_DIR/binutils
wget https://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz
tar -xzvf binutils-2.25.tar.gz
mkdir build-binutils
cd build-binutils
../binutils-2.25/configure --target=i686-aldebaran-linux-gnu --prefix="$PREFIX/$NAOQI_SDK/crosstoolchain/cross/atom" --with-sysroot="$PREFIX/$NAOQI_SDK/crosstoolchain/cross/atom/i686-aldebaran-linux-gnu/sysroot" --enable-gold
make
make install

# Patch glibc.modulemap
cd $PREFIX/$NAOQI_SDK/crosstoolchain/staging/i686-aldebaran-linux-gnu/home/nao/swift-tc/lib/swift/linux/i686
cp glibc.modulemap glibc.modulemap.orig
sed -e "s@header \".*/usr/@header \"$PREFIX/$NAOQI_SDK/crosstoolchain/staging/i686-aldebaran-linux-gnu/usr/@g" glibc.modulemap.orig > glibc.modulemap

# Symlink some files
cd $PREFIX/$NAOQI_SDK/crosstoolchain/staging/i686-aldebaran-linux-gnu/usr/lib
ln -s ../../../../lib/gcc/i686-aldebaran-linux-gnu/4.9.2/crtbegin.o .
ln -s ../../../../lib/gcc/i686-aldebaran-linux-gnu/4.9.2/crtbeginS.o .
ln -s ../../../../lib/gcc/i686-aldebaran-linux-gnu/4.9.2/crtendS.o .
ln -s ../../../../lib/gcc/i686-aldebaran-linux-gnu/4.9.2/crtend.o .

cd $WD
