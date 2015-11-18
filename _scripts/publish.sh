#!/bin/sh

if [ -z "$1" ]
    then
        echo "No draft file found"
        exit
fi

git add $1
git mv $1 _posts/`date +"%Y-%m-%d"`-`basename $1`
