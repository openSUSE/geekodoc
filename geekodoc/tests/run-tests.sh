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
# Date:   2016-2018

VALIDATOR="xmllint"
PROG=${0##*/}
PROGDIR=${0%/*}
# Needed to be able to run it from different directories
SCHEMA=${PROGDIR}/../rng/geekodoc5-flat.rng
SCHEMA=$(readlink -f ${SCHEMA})
ERRORS=0

SUCCESS=0
FAILURE=1

MAKE=1

TEST_CATEGORY=all

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
    echo -e "\e[1;39mINFO: $1\e[0m"
}

function logwarn() {
    echo -e "\e[1;95mWARN: $1\e[0m"
}

function validate_with_jing {
    local _RNG=$1
    local _XML=$2
    local _ERROR=${2%*.xml}.err
    local result
    jing $_RNG $_XML >$_ERROR
    return $?
}

function validate_with_xmllint {
    local _RNG=$1
    local _XML=$2
    local _ERROR=${2%*.xml}.err
    xmllint --noout --relaxng $_RNG $_XML 2>$_ERROR
    return $?
}

function validator {
    case "$VALIDATOR" in
     "xmllint")
        validate_with_xmllint "$1" "$2"
        return $?
        ;;
     "jing")
        validate_with_jing "$1" "$2"
        return $?
        ;;
     *)
        echo "Wrong validator: $VALIDATOR" 1>&2
        ;;
    esac
    return 1
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
   -t, --test  Choose the test category:
               * 'bad' check only tests which are expected to fail
               * 'good' check only tests which are expected to succeed
               * 'all' chooses both (default)
   -n, --noremake Do not run make on the geekodoc/rng/ directory
               (useful for running this in the RPM %check section)
EOF_helptext
}


function test_check()
{
    local TEST=$1
    local RESULT=$2
    local RESULTSTR=

    RESULTSTR="\e[1;32mPASSED\e[0m"
    case "$1" in
        good)
            if [ "$RESULT" -ne 0 ]; then
                RESULTSTR="\e[1;31mFAILED\e[0m"
            fi
            ;;
        bad)
            if [ "$RESULT" -eq 0 ]; then
                RESULTSTR="\e[1;31mFAILED\e[0m"
            fi
            ;;
        *)
            ;;
    esac
    echo $RESULTSTR
}

function count_errors()
{
    case "$1" in
        good)
            if [ "$2" -ne 0 ]; then
                ERRORS=$(($ERRORS + 1))
            fi
            ;;
        bad)
            if [ "$2" -eq 0 ]; then
                ERRORS=$(($ERRORS + 1))
            fi
            ;;
    esac
}

function test_files() {
    local DIR=$1
    local CHECK=$2
    local GOOD_OR_BAD=${DIR##*/}
    local result
    local resultstr
    local re='^[0-9]+$'

    for xmlfile in $DIR/*.xml; do
       validator $SCHEMA $xmlfile
       result=$?
       resultstr=$(test_check $GOOD_OR_BAD $result)
       count_errors $GOOD_OR_BAD $result
       loginfo "Validating '$xmlfile'... $resultstr"
    done
}

# -----
#
ARGS=$(getopt -o h,V:,t:,n -l help,validator:,test:,nomake -n "$PROG" -- "$@")
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
                 echo "ERROR: Wrong validator '$2'" 2>/dev/stderr
                 exit 10
                 ;;
            esac
            shift 2
            ;;
        -t|--test)
            case "$2" in
              all)
                # don't do anything, this is the default
                ;;
              bad|good)
                TEST_CATEGORY=$2
                shift 2
                ;;
              -*)
                # another option, don't use it
                shift 1
                ;;
              *)
                logerror "Expected 'all', 'bad', or 'good' for option $1"
                exit 1
                ;;
            esac
            ;;
        -n|--nomake)
            MAKE=0
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [[ $MAKE -eq 1 ]]; then
  loginfo "Making flat GeekoDoc..."
  make -C "$PROGDIR/../rng" > /dev/null
  [[ ! $? -eq 0 ]] && logerror --fatal "Make error. Quitting."
else
  loginfo "Not making flat GeekoDoc"
fi

loginfo "Using validator '$VALIDATOR'"
loginfo "Selected category: '$TEST_CATEGORY'"

# Cleanup any *.err files first...
rm -f $PROGDIR/*.err 2>/dev/null


case "$TEST_CATEGORY" in
  all)
    test_files $PROGDIR/good test_check_good
    echo "----------------------------------"
    test_files $PROGDIR/bad test_check_bad
    ;;
  good)
    test_files $PROGDIR/good test_check_good
    ;;
  bad)
    test_files $PROGDIR/bad test_check_bad
    ;;
esac


# Remove any error files which are zero bytes, but keep the ones which
# contains error messages
for errfile in $PROGDIR/*.err; do
    [[ -s $errfile ]] || rm $errfile 2>/dev/null
done

echo
if [ 0 -eq "$ERRORS" ]; then
    loginfo "Found\e[1;32m $ERRORS errors\e[0m. Congratulations! :-)"
    exit 0
else
    loginfo "Found\e[1;31m $ERRORS error(s)\e[0m. :-("
    exit 1
fi
