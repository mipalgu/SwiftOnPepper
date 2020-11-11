#! /bin/sh
set -e

source tags.sh
source setup.sh

mkdir -p $BUILD_DIR
rm -r $CONTEXT_DIR
mkdir -p $CONTEXT_DIR

if [ ! -f nao_swift/pepper/build.sh ]
then
    git submodule update --init --recursive
    git submodule foreach --recursive 'git fetch --tags'
fi

if [ -z ${CHECKOUT_VERSION+x} ]
then
    CHECKOUT_VERSION=`compute_nearest_tag $SWIFT_VERSION`
fi

function checkout_submodule() {
    local current_tag=`fetch_current_tag`
    local previous_tag=`fetch_previous_tag $BUILD_DIR/.swift-version`
    if [[ "$current_tag" == "none" || ("$current_tag" != "$previous_tag") ]]
    then
        `cd $WD/nao_swift && git checkout $CHECKOUT_VERSION`
    fi
    rm -f $CONTEXT_DIR/nao_swift.tar.gz
    tar -czf $CONTEXT_DIR/nao_swift.tar.gz nao_swift
    echo "$CHECKOUT_VERSION" > $BUILD_DIR/.swift-version
}


cp $WD/Dockerfile.in $DOCKERFILE
echo "" >> $DOCKERFILE

ARGS="--build-arg SWIFTVER=\"$SWIFT_VERSION\" --build-arg PARALLEL=\"$PARALLEL\" --build-arg LIBCXXFLAG=\"$LIBCXXFLAG\""

cp $CROSS_TOOLCHAIN_ZIP $CONTEXT_DIR/
if [[ "$DEBUG" == 1 ]]
then
    cp $KEYFILE $CONTEXT_DIR/id_rsa
    ARGS="$ARGS --build-arg SSH_USER=\"$SSH_USERNAME\" --build-arg GIT_USERS_NAME=\"`git config user.name`\" --build-arg GIT_USERS_EMAIL=\"`git config user.email`\" --build-arg CHECKOUT_VERSION=\"$CHECKOUT_VERSION\""
    cat Dockerfile.debug >> $DOCKERFILE
    echo "" >> $DOCKERFILE
else
    cat Dockerfile.default >> $DOCKERFILE
    echo "" >> $DOCKERFILE
    checkout_submodule
fi
echo "COPY $CROSS_TOOLCHAIN_BASENAME /root/src/nao_swift/pepper/" >> $DOCKERFILE
echo "RUN cd /root/src/nao_swift/pepper && unzip $CROSS_TOOLCHAIN_BASENAME" >> $DOCKERFILE
echo "" >> $DOCKERFILE
echo "ARG PARALLEL=1" >> $DOCKERFILE
echo "ARG LIBCXXFLAG=\"\"" >> $DOCKERFILE
echo "" >> $DOCKERFILE
while read p; do
    first_word=`echo "$p" | cut -f 1 -d " " -`
    second_word=`echo "$p" | cut -f 2 -d " " -`
    if [[ "$first_word" == "source" ]]
    then
        echo "RUN cd /root/src/nao_swift/pepper && \\" >> $DOCKERFILE
        echo "    export SWIFTENV_ROOT="\$SWIFTENV_ROOT_ARG" && \\" >> $DOCKERFILE
        echo "    export PATH="\$SWIFTENV_ROOT/bin:\$PATH" && \\" >> $DOCKERFILE
        echo "    eval "\$\(swiftenv init -\)" && \\" >> $DOCKERFILE
        echo "    ./$second_word -j\$PARALLEL\$LIBCXXFLAG -s \$SWIFTVER" >> $DOCKERFILE
    fi
done <$WD/nao_swift/pepper/build.sh

eval "docker image build $ARGS -t mipal-pepper-swift-crosstoolchain-build -f $DOCKERFILE $CONTEXT_DIR"
