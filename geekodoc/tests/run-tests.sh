#!/bin/bash
#
# Run test cases
#
# Author: Thomas Schraitle
# Date:   December 2016

SCHEMA=../rng/geekodoc5-flat.rng
PROG=${0##*/}
ERRORS=0

function validate_with_jing {
    local _RNG=$1
    local _XML=$2
    local _ERROR=${2%*.xml}.err
    jing $_RNG $_XML
}

function validate_with_xmllint {
    local _RNG=$1
    local _XML=$2
    local _ERROR=${2%*.xml}.err
    xmllint --noout --relaxng $_RNG $_XML 2>$_ERROR
    echo $?
}

function print_help {
    cat <<EOF_helptext
Run all the test cases

Usage:
   ${PROG} [-h|--help] [OPTIONS]

Options:
   -h, --help  Shows this help message
EOF_helptext
}

# -----
#
ARGS=$(getopt -o h -l help -n "$PROG" -- "$@")
eval set -- "$ARGS"
while true ; do
    case "$1" in
        -h|--help)
            print_help
            exit
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

# Iterating over all XML files inside this directory...
for xmlfile in *.xml; do
    result=$(validate_with_xmllint $SCHEMA $xmlfile )
    if [[ $result = '0' ]]; then
        result="\e[1;32mPASSED\e[0m"
    else
        result="\e[1;31mFAILED\e[0m"
        ERRORS=$(($ERROR + 1))
    fi
    echo -e "Validating '$xmlfile'... $result"
done

echo
if [[ $ERRORS -eq 0 ]]; then
    echo -e -n "Found\e[1;32m $ERRORS error(s)\e[0m. "
    echo "Congratulations! :-)"
    exit 0
else
    echo -e -n "Found\e[1;31m $ERRORS error(s)\e[0m. "
    echo ":-("
    exit 1
fi