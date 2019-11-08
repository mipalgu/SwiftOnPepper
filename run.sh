#! /bin/sh

docker run -p 6080:80 -p 6022:22 --rm -it --name pepper-swift mipal-pepper-swift-crosstoolchain-build
