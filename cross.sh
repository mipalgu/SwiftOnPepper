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
function build_binutils() {
    local install_prefix="$PREFIX/$NAOQI_SDK/crosstoolchain/cross/atom"
    local previous_prefix=`cat "$SRC_DIR/binutils/.binutils"`
    if [[ "$previous_prefix" != "$install_prefix" ]]
    then
        mkdir -p $SRC_DIR/binutils
        cd $SRC_DIR/binutils
        if [ ! -f "$SRC_DIR/binutils/binutils-2.25.tar.gz" ]
        then
            wget https://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz
            tar -xzvf binutils-2.25.tar.gz
        fi
        rm -rf build-binutils
        mkdir -p build-binutils
        cd build-binutils
        ../binutils-2.25/configure --target=i686-aldebaran-linux-gnu --prefix="$install_prefix" --with-sysroot="$install_prefix/i686-aldebaran-linux-gnu/sysroot" --enable-gold
        make
        cd ..
        echo "$install_prefix" > .binutils
    fi
    cd $SRC_DIR/binutils/build-binutils
    make install
    cd $WD
}
build_binutils

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
