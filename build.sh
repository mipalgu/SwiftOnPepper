#! /bin/sh

docker image build --build-arg SSH_USER=`whoami` --build-arg GIT_USERS_NAME="`git config user.name`" --build-arg GIT_USERS_EMAIL="`git config user.email`" --build-arg SWIFTVER="5.1.2" -t mipal-pepper-swift-crosstoolchain-build .
