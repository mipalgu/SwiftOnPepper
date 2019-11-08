#! /bin/sh

docker image build --build-arg SSH_USER=`whoami` -t mipal-pepper-swift-crosstoolchain-build .
