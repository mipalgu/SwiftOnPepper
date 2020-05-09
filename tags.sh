#! /bin/sh
set -e

function difference() {
    >&2 echo "1: $1, 2: $2"
    echo "`expr $1 - $2`"
}

function major_version() {
    echo "$1" | cut -f 1 -d "." -
}

function minor_version() {
    echo "$1" | cut -f 2 -d "." -
}

function major_difference() {
    local target_major=$1
    local tag=$2
    local new_major_version=`major_version $tag`
    echo "`difference $target_major $new_major_version`"
}

function minor_difference() {
    local target_minor=$1
    local tag=$2
    local new_minor_version=`major_version $tag`
    echo "`difference $target_minor $new_minor_version`"
}

function compute_nearest_tag() {
    local target_version=$1
    local tags=`cd $WD/nao_swift && git tag -l`
    local target_major=`major_version $target_version`
    local target_minor=`minor_version $target_version`
    local found_tag=`echo "$tags" | head -n 1`
    local major_difference=`major_difference $target_major $found_tag`
    local minor_difference=`minor_difference $target_minor $found_tag`
    if [[ $major_difference > 0 || ($major_difference < 0 && ($minor_difference > 0)) ]]
    then
        major_difference="-99999"
    fi
    for tag in $tags
    do
        if [ "$tag" == "$target_version" ]
        then
            echo "$target_version"
            return 0
        fi
        local new_major_difference=`major_difference $target_major $tag`
        local new_minor_difference=`minor_difference $target_minor $tag`
        if [[ $new_major_difference < 0 && ($new_major_difference > $major_difference) ]]
        then
            found_tag=$tag
            major_difference=$new_major_difference
            minor_difference=$new_minor_difference
        elif [[ $new_major_difference == $major_difference && ($new_minor_difference > $minor_difference) ]]
        then
            found_tag=$tag
            major_difference=$new_major_difference
            minor_difference=$new_minor_difference
        fi
    done
    echo "$found_tag"
}

function fetch_current_tag() {
    local text=`cd $WD/nao_swift && git status | head -n 1`
    local first_word=`echo "$text" | cut -f 1 -d " " -`
    if [ "$first_word" != "HEAD" ]
    then
        echo "none"
        return
    fi
    echo "`echo "$text" | cut -f 4 -d " " -`"
}

function fetch_previous_tag() {
    local previous_tag=`cat $BUILD_DIR/.swift-version 2>/dev/null`
    if [ "$previous_tag" == "" ]
    then
        echo "none"
        return 0
    fi
    echo "$previous_tag"
}
