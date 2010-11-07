#!/bin/bash

C=2
GREP='.'
if [ $# -eq 1 ]
then
    C=$1
    GREP='WORKS'
fi

bash wiki-tests.sh Pending sc ca update | grep -C $C "$GREP"

bash wiki-tests.sh Pending ca sc update | grep -C $C "$GREP"

