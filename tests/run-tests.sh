#!/bin/bash -i
#
# Run test cases
#
# The test cases are separated into "good" and "bad":
#
# * good are tests which MUST SUCCEED, otherwise it is an error
# * bad are tests which MUST FAIL, otherwise it is an error
#
# Author: Thomas Schraitle
# Date:   2016-2021

# set -x

VALIDATOR="xmllint"
PROG=${0##*/}
PROGDIR=${0%/*}

# Needed to be able to run it from different directories
GEEKODOC_V1="${PROGDIR}/../build/geekodoc/rng/1_5.1/geekodoc-v1-flat.rng"
GEEKODOC_V1=$(readlink -f "${GEEKODOC_V1}")
GEEKODOC_V2="${PROGDIR}/../build/geekodoc/rng/2_5.2/geekodoc-v2-flat.rng"
GEEKODOC_V2=$(readlink -f "${GEEKODOC_V2}")

# SCHEMA=${PROGDIR}/../rng/geekodoc5-flat.rng
# SCHEMA=$(readlink -f ${SCHEMA})
ERRORS=0
ERRORFILE="${PROGDIR}/last-test-run-errors"

# Which versions of Geekodoc should be tested?
# valid: 1, 2, both
GEEKODOC="both"

SUCCESS=0
FAILURE=1


export LANG=C

function logerror() {
    local fatal=0
    if [[ $1 == '--fatal' ]]; then
        fatal=1
        shift
    fi
    echo -e "\e[1;31mERROR: $1\e[0m"
    [[ $fatal -ne 0 ]] && exit 1
}

function loginfo() {
    local extraoptions=
    if [[ $1 == '-n' ]]; then
        extraoptions='-n'
        shift
    fi
    echo -e $extraoptions "\e[1;39mINFO: $1\e[0m"
}

function logwarn() {
    echo -e "\e[1;95mWARN: $1\e[0m"
}

function validator() {
    case "$VALIDATOR" in
     "xmllint")
        # sed '$ d' removes the last line in which xmllint just prints the
        # validation status (which we don't want cluttering our output).
        xmllint --noout --relaxng "$1" "$2" 2>&1 | sed '$ d'
        ;;
     "jing")
        jing "$1" "$2"
        ;;
     *)
        echo "Unrecognized validator: $VALIDATOR" 1>&2
        ;;
    esac
    return 1
}

function print_help {
    cat <<EOF_helptext
Run all the test cases using GeekoDoc schema v1 and v2

Usage:
   ${PROG} [-h|--help] [OPTIONS]

Options:
   -h, --help  Shows this help message
   -g VERSION, --geekodoc VERSION
               Choose Geekodoc version to test. Valid values are
               "1", "2", or "both" (default)
   -V VALIDATOR, --validator VALIDATOR
               Choose to validate either with "jing" or "xmllint"
EOF_helptext
}


function test_check()
{
    local TEST="$1"
    local RESULT="$2"
    local RESULTSTR=

    RESULTSTR="\e[1;32mPASSED\e[0m"
    case "$TEST" in
        good)
            if [[ ! "$RESULT" == '' ]]; then
                RESULTSTR="\e[1;31mFAILED\e[0m"
                ERRORS=$((ERRORS + 1))
            fi
            ;;
        bad)
            if [[ "$RESULT" == '' ]]; then
                RESULTSTR="\e[1;31mFAILED\e[0m"
                ERRORS=$((ERRORS + 1))
            fi
            ;;
        *)
            ;;
    esac
    echo -e "$RESULTSTR"
}

function test_files() {
    local DIR=$1
    local CHECK=$2
    local SCHEMA=${3:?GeekoDoc schema not set}
    local GOOD_OR_BAD=${DIR##*/}
    local result

    # Skip, if directory is empty
    if ! find "$DIR" -mindepth 1 -name \*.xml | read; then
       logwarn "No XML files found in $DIR, skipping"
       return
    fi

    for xmlfile in $DIR/*.xml; do
       loginfo -n "Validating '$xmlfile'... "
       wellformedness=$(xmllint --noout --noent "$xmlfile" 2>&1)
       if [[ ! $wellformedness == '' ]]; then
           # In this case, we always want to say "FAILED", so this usage is correct.
           # (But we are abusing the existing test_check() function somewhat.)
           test_check good 'not good'
           echo -e "$wellformedness"
           logerror --fatal "Test case is not well-formed: '$xmlfile'. Quitting."
       fi
       result=$(validator "$SCHEMA" "$xmlfile")
       test_check "$GOOD_OR_BAD" "$result"
       if [[ ! "$result" == '' ]]; then
           [[ $GOOD_OR_BAD == 'good' ]] && echo -e "$result"
           echo "###### Errors in '$xmlfile' ######" >> "$ERRORFILE"
           echo -e "\n$result\n\n" >> "$ERRORFILE"
       fi
    done
}


function validate_against()
{
    local msg="$1"
    local ver="$2"
    local geekodoc_ver="$3"
    loginfo "### $msg $ver"
    test_files "$PROGDIR/$ver/good" test_check_good "$geekodoc_ver"
    echo "----------------------------------"
    test_files "$PROGDIR/$ver/bad" test_check_bad "$geekodoc_ver"
}


function validate_against_v1()
{
    validate_against "Testing GeekoDoc" "v1" "$GEEKODOC_V1"
}


function validate_against_v2()
{
    validate_against "Testing GeekoDoc" "v2" "$GEEKODOC_V2"
}

# -----
#
ARGS=$(getopt -o g:,h,V: -l geekodoc:,help,validator: -n "$PROG" -- "$@")
eval set -- "$ARGS"
while true ; do
    case "$1" in
        -h|--help)
            print_help
            exit
            shift
            ;;
        -V|--validator)
            case "$2" in
                'xmllint' | 'jing')
                 VALIDATOR="$2"
                 ;;
               *)
                 print_help
                 echo "ERROR: Unrecognized validator '$2'" 2>/dev/stderr
                 exit 10
                 ;;
            esac
            shift 2
            ;;
        -g|--geekodoc)
            case "$2" in
              1|2|both|b)
                GEEKODOC="$2"
                ;;
              *)
                logerror "Expected '1', '2', or 'both'/'b' for --geekodoc, but got '$2'"
                exit 1
                ;;
            esac
            shift 2
            ;;
        --)
            shift
            break
            ;;
    esac
done


if [[ ! -e $GEEKODOC_V1 ]]; then
    logerror --fatal "No flat GeekoDoc v1 schema available. Use the build.sh script."
fi
if [[ ! -e $GEEKODOC_V2 ]]; then
    logerror --fatal "No flat GeekoDoc v2 schema available. Use the build.sh script."
fi


loginfo "Using validator '$VALIDATOR'"
loginfo "Test GeekoDoc version(s): $GEEKODOC"

[[ -e "$ERRORFILE" ]] && rm -r "$ERRORFILE" 2> /dev/null

case "$GEEKODOC" in
    both|b)
        validate_against_v1
        validate_against_v2
        ;;
    1)
        validate_against_v1
        ;;
    2)
        validate_against_v2
        ;;
    *)
        logerror "Expected '1', '2', or 'both'/'b' for --geekodoc, but got '$1'"
        ;;
esac



# echo
loginfo "Find all validation errors in $ERRORFILE"
if [ 0 -eq "$ERRORS" ]; then
    loginfo "Found\e[1;32m $ERRORS errors\e[0m. Congratulations! :-)"
    exit 0
else
    loginfo "Found\e[1;31m $ERRORS error(s)\e[0m. :-("
    exit 1
fi
