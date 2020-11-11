#! /bin/sh
set -e

function difference() {
    echo "`expr $2 - $1`"
}

function major_version() {
    echo "$1" | cut -f 1 -d "." -
}

function minor_version() {
    echo "$1" | cut -f 2 -d "." -
}

function patch_version() {
    local version=`echo "$1" | cut -f 3 -d "." -`
    if [[ "$version" == "" ]]
    then
        echo "0"
        return 0
    fi
    echo "$version"
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
    local new_minor_version=`minor_version $tag`
    echo "`difference $target_minor $new_minor_version`"
}

function patch_difference() {
    local target_patch=$1
    local tag=$2
    local new_patch_version=`patch_version $tag`
    echo "`difference $target_patch $new_patch_version`"
}

function compute_nearest_tag() {
    local target_version=$1
    local tags=`cd $WD/nao_swift && git tag -l`
    local target_major=`major_version $target_version`
    local target_minor=`minor_version $target_version`
    local target_patch=`patch_version $target_version`
    local found_tag=`echo "$tags" | head -n 1`
    local major_difference=`major_difference $target_major $found_tag`
    local minor_difference=`minor_difference $target_minor $found_tag`
    local patch_difference=`patch_difference $target_patch $found_tag`
    if [[ $major_difference -gt 0 || ($major_difference -lt 0 && ($minor_difference -gt 0)) ]]
    then
        major_difference="-99999"
    fi
    for tag in $tags
    do
        local new_major_difference=`major_difference $target_major $tag`
        local new_minor_difference=`minor_difference $target_minor $tag`
        local new_patch_difference=`patch_difference $target_patch $tag`
        if [[ "$tag" == "$target_version" || ($new_major_difference == 0 && ($new_minor_difference == 0 && ($new_patch_difference == 0))) ]]
        then
            echo "$tag"
            return 0
        fi
        if [[ $new_major_difference -lt 0 && ($new_major_difference -gt $major_difference) ]]
        then
            found_tag=$tag
            major_difference=$new_major_difference
            minor_difference=$new_minor_difference
            patch_difference=$new_patch_difference
        elif [[ $new_major_difference -eq 0 && ($new_minor_difference -lt 0 && ($new_minor_difference -gt $minor_difference)) ]]
        then
            found_tag=$tag
            major_difference=$new_major_difference
            minor_difference=$new_minor_difference
            patch_difference=$new_patch_difference
        elif [[ $new_major_difference -eq 0 && ($new_minor_difference -eq 0 && ($new_patch_difference -lt 0 && ($new_patch_different -gt $patch_difference))) ]]
        then
            found_tag=$tag
            major_difference=$new_major_difference
            minor_difference=$new_minor_difference
            patch_difference=$new_patch_difference
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
    local cacheFile=$1
    local previous_tag=`cat $cacheFile 2>/dev/null`
    if [ "$previous_tag" == "" ]
    then
        echo "none"
        return 0
    fi
    echo "$previous_tag"
}
