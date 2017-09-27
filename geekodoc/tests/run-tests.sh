#!/bin/bash
#
# Run test cases
#
# Author: Thomas Schraitle
# Date:   December 2016

VALIDATOR="xmllint"
PROG=${0##*/}
PROGDIR=${0%/*}
# Needed to be able to run it from different directories
SCHEMA=${PROGDIR}/../rng/geekodoc5-flat.rng
SCHEMA=$(readlink -f ${SCHEMA})
ERRORS=0

function validate_with_jing {
    local _RNG=$1
    local _XML=$2
    local _ERROR=${2%*.xml}.err
    jing $_RNG $_XML >$_ERROR
    echo $?
}

function validate_with_xmllint {
    local _RNG=$1
    local _XML=$2
    local _ERROR=${2%*.xml}.err
    xmllint --noout --relaxng $_RNG $_XML 2>$_ERROR
    echo $?
}

function validator {
    case "$VALIDATOR" in
     "xmllint")
        validate_with_xmllint "$1" "$2"
        ;;
     "jing")
        validate_with_jing "$1" "$2"
        ;;
     *)
        echo "Wrong validator: $VALIDATOR" 1>&2
        ;;
    esac
}

function print_help {
    cat <<EOF_helptext
Run all the test cases using ${SCHEMA}

Usage:
   ${PROG} [-h|--help] [OPTIONS]

Options:
   -h, --help  Shows this help message
   -V VALIDATOR, --validator VALIDATOR
               Choose to validate either with "jing" or "xmllint"
EOF_helptext
}


VALIDATOR_FUNC=validate_with_xmllint

# -----
#
ARGS=$(getopt -o h,V: -l help,validator: -n "$PROG" -- "$@")
eval set -- "$ARGS"
while true ; do
    case "$1" in
        -h|--help)
            print_help
            exit
            shift
            ;;
        -V|--validator)
            if [ 'xmllint' = "$2" ] || [ 'jing' = "$2" ]; then
                VALIDATOR="$2"
            else
               echo "ERROR: Wrong validator '$2' Choose either " \
                    "'xmllint' or 'jing'" 2>/dev/stderr
               exit 10
            fi
            shift 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

echo "INFO: Using validator '$VALIDATOR'..."

# Cleanup any *.err files first...
rm -f $PROGDIR/*.err 2>/dev/null

# Iterating over all XML files inside this directory...
for xmlfile in $PROGDIR/*.xml; do
    result=$(validator $SCHEMA $xmlfile )
    if [[ $result = '0' ]]; then
        RESULTSTR="\e[1;32mPASSED\e[0m"
    else
        RESULTSTR="\e[1;31mFAILED\e[0m"
        ERRORS=$(($ERROR + 1))
    fi
    echo -e "Validating '$xmlfile'... $RESULTSTR"
    if [[ $result != '0' ]]; then
        cat "${xmlfile%*.xml}.err" 1>&2
        echo "----------------------------------------------"
    fi
done

echo
if [[ $ERRORS -eq 0 ]]; then
    echo -e "Found\e[1;32m $ERRORS errors\e[0m. Congratulations! :-)"
else
    echo -e "Found\e[1;31m $ERRORS error(s)\e[0m. :-("
    exit 1
fi

# Remove any error files which are zero bytes, but keep the ones which
# contains error messages
for errfile in $PROGDIR/*.err; do
    [[ -s $errfile ]] || rm $errfile 2>/dev/null
done

exit 0
